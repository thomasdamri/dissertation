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
#
class Assessment < ApplicationRecord

  # Module id, needed when submitting form
  attr_accessor :mod

  # Destroy all dependent criteria when removing object
  has_many :criteria, dependent: :destroy
  has_many :assessment_results, through: :criteria
  belongs_to :uni_module
  has_many :student_weightings, dependent: :destroy
  has_many :team_grades, dependent: :destroy

  accepts_nested_attributes_for :criteria, reject_if: :all_blank, allow_destroy: true

  # Name of the assessment must not be the same as another assessment for the same module
  validates :name, uniqueness: {scope: :uni_module}, presence: true
  validates :date_opened, presence: true
  validates :date_closed, presence: true

  validates_with AssessmentValidator

  # Returns true if the given user has completed the assessment
  def completed_by?(user)
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

  # Given a team, generates the weightings for each student in it
  def generate_weightings(team)
    # First generate the total score for each user across all assessed criteria
    assessed_crits = criteria.where(assessed: true)

    # If no-one has filled in the assessment, then set all weightings to 1
    if AssessmentResult.where(criterium: assessed_crits).count == 0
      team.users.each do |user|
        sw = StudentWeighting.find_or_initialize_by(user: user, assessment_id: id)
        sw.update_weighting 1, 0
      end
      # Do not continue to rest of calculations
      return
    end

    # Holds the total scores for each user
    user_total_dict = {}

    # Iterate over each user and sum their scores over the assessed criteria
    team.users.each do |user|
      user_total_dict[user.id] = 0
      # Get all responses for each crit where the user is the target
      assessed_crits.each do |crit|
        results = crit.assessment_results.where(target: user)
        results.each do |result|
          user_total_dict[user.id] += result.value.to_f
        end
      end
    end

    average_score = user_total_dict.values.sum() / team.users.count

    team.users.each do |user|
      sw = StudentWeighting.find_or_initialize_by(user: user, assessment: self)
      # Calculate the weighting
      weighting = user_total_dict[user.id] / average_score
      num_results = assessment_results.count
      # Update this in the database
      sw.update_weighting(weighting, num_results)
    end

  end

end
