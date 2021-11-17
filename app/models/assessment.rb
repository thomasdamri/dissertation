# == Schema Information
#
# Table name: assessments
#
#  id            :bigint           not null, primary key
#  name          :string(255)
#  uni_module_id :bigint
#  date_opened   :date
#  date_closed   :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  show_results  :boolean
#
class Assessment < ApplicationRecord

  # Module id, needed when submitting form
  attr_accessor :mod

  # Destroy all dependent criteria when removing object
  has_many :criteria, dependent: :destroy
  #has_many :assessment_results, through: :criteria
  belongs_to :uni_module
  has_many :student_weightings, dependent: :destroy
  #has_many :team_grades, dependent: :destroy

  accepts_nested_attributes_for :criteria, reject_if: :all_blank, allow_destroy: true

  # Name of the assessment must not be the same as another assessment for the same module
  validates :name, uniqueness: {scope: :uni_module}, presence: true
  validates :date_opened, presence: true
  validates :date_closed, presence: true
  validates :show_results, inclusion: { in: [true, false] }

  # Checks opening date is before closing date
  validates_with AssessmentValidator

  # Returns true if this assessment has had team grades uploaded for it
  def has_team_grades?
    if team_grades.count == 0
      false
    else
      true
    end
  end

  # Returns true if the given user has completed the assessment
  def completed_by?(user)
    if criteria.size == 0
      return false
    end
    # Check if the user has any authored results for this assessment's criteria
    if user.author_results.pluck(:criterium_id).include? criteria.first.id
      true
    else
      false
    end
  end

  # Returns the number of people in a team that have completed the assessment
  def num_completed(team)
    comp = 0
    team.users.each do |user|
      if completed_by? user
        comp += 1
      end
    end
    comp
  end

  # Returns true if the current date is between the opening and closing date
  def within_fill_dates?
    Date.today.between?(self.date_opened, self.date_closed) ? true : false
  end

  # Generates the individual weightings for all students in a given team according to the WebPA system
  def generate_weightings(team)

    # Find all criteria in this assessment that are assessed
    assessed_crits = criteria.where(assessed: true)

    # If there are no results for assessed criteria, give everyone the same weighting of 1 and return
    if AssessmentResult.where(criterium: assessed_crits).count == 0
      team.users.each do |user|
        sw = StudentWeighting.find_or_initialize_by(user_id: user.id, assessment_id: id)
        sw.update_weighting 1, 0
      end
      return
    end

    # This hash will hold the weighting factor for each student
    student_weights = {}

    team.users.each do |user|
      # Initialise the hash with each student's id number
      student_weights[user.id] = 0
    end


    team.users.each do |marker|
      # Sum up the marks the student gave out in assessed criteria
      author_results = assessment_results.where(criterium: assessed_crits, author_id: marker.id)
      marks_given = 0
      author_results.each do |res|
        marks_given += res.criterium.weighting * res.value.to_f
      end

      # Avoid division by 0 if the user has not filled in the form
      unless marks_given == 0

        # For each markee, work out the proportion of marks given out by the marker to them
        team.users.each do |markee|
          # Sum the total number of marks across each criteria given to each user
          given_to_markee = 0
          author_results.where(target_id: markee.id).each do |res|
            given_to_markee += res.criterium.weighting * res.value.to_f
          end
          student_weights[markee.id] += given_to_markee / marks_given
        end
      end

    end

    # Check for how many students filled in the assessment so far
    num_complete = num_completed(team)
    unless num_complete == team.users.count
      # If some students have not filled out the assessment, increase everyone's marks to accommodate this
      mult_factor = team.users.count.to_f / num_complete.to_f
      team.users.each do |user|
        student_weights[user.id] = student_weights[user.id] * mult_factor
      end
    end

    # Add the weightings to the database
    team.users.each do |user|
      # Find existing student weighting for this assessment, or create a new one
      sw = StudentWeighting.find_or_initialize_by(user: user, assessment_id: id)
      # Do not update the weighting if it has been manually set
      unless sw.manual_set
        num_results = assessment_results.count
        # Update this in the database
        sw.update_weighting(student_weights[user.id], num_results)
      end
    end

  end

end
