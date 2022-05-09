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

  # Destroy all dependent question when removing object
  has_many :questions, dependent: :destroy
  # Have access to all assessment results 
  has_many :assessment_results, through: :questions
  # Assessment belongs to uni module
  belongs_to :uni_module
  has_many :student_weightings, dependent: :destroy
  has_many :team_grades, dependent: :destroy

  # Questions can be nested, cannot be blank
  accepts_nested_attributes_for :questions, reject_if: :all_blank, allow_destroy: true

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
  def completed_by?(student_team)
    if questions.size == 0
      return false
    end
    # Check if the user has any authored results for this assessment's question
    if student_team.author_results.pluck(:question_id).include? questions.first.id
      true
    else
      false
    end
  end

  # Returns the number of people in a team that have completed the assessment
  def num_completed(team)
    comp = 0
    team.student_teams.each do |student_team|
      if completed_by? student_team
        comp += 1
      end
    end
    comp
  end

  # Returns the individuals grade
  def get_individual_grade(student_team_id)
    student_team = StudentTeam.find_by(id: student_team_id)

    team_grade = student_team.team.team_grades.where(assessment_id: self.id).first
    if(team_grade.nil?)
      return "ERROR"
    end

    # Try to find user's individual weighting
    weight = student_team.student_weightings.where(assessment_id: self.id).first
    if(weight.nil?)
      return "ERROR"
    end
    return (team_grade.grade * weight.weighting)
  end

  # Returns true if the current date is between the opening and closing date
  def within_fill_dates?
    Date.today.between?(self.date_opened, self.date_closed) ? true : false
  end

  # Generates the individual weightings for all students in a given team according to the WebPA system
  def generate_weightings(team)

    # Find all question in this assessment that are assessed
    assessed_crits = questions.where(assessed: true)
    num_results = 0

    # If there are no results for assessed question, give everyone the same weighting of 1 and return
    if AssessmentResult.where(question: assessed_crits).count == 0
      team.student_teams.each do |student_team|
        sw = StudentWeighting.find_or_initialize_by(student_team_id: student_team.id, assessment_id: id)
        sw.update_weighting 1, 0
        puts(sw.inspect)
      end
      return
    end

    # This hash will hold the weighting factor for each student
    student_weights = {}

    team.student_teams.each do |student_team|
      # Initialise the hash with each student's id number
      student_weights[student_team.id] = 0
    end

    team.student_teams.each do |student_team_marker|
      author_results = []
      self.questions.each do |q|
        q.assessment_results.each do |ar|
          if(q.assessed && ar.author_id==student_team_marker.id)
            author_results.append(ar)
            num_results += 1
          end
        end
      end

      # Sum up the marks the student gave out in assessed question
      marks_given = 0
      author_results.each do |res|
        marks_given += res.question.weighting * res.value.to_f
      end

      # Avoid division by 0 if the user has not filled in the form
      unless marks_given == 0
        # For each markee, work out the proportion of marks given out by the marker to them
        team.student_teams.each do |student_team_markee|
          # Sum the total number of marks across each question given to each user
          given_to_markee = 0
          author_results.each do |res|
            if (res.target_id == student_team_markee.id)
              given_to_markee += res.question.weighting * res.value.to_f
            end
          end
          student_weights[student_team_markee.id] += given_to_markee / marks_given
        end
      end

    end

    # Check for how many students filled in the assessment so far
    num_complete = num_completed(team)
    unless num_complete == team.users.count
      # If some students have not filled out the assessment, increase everyone's marks to accommodate this
      mult_factor = team.users.count.to_f / num_complete.to_f
      team.student_teams.each do |student_team|
        student_weights[student_team.id] = student_weights[student_team.id] * mult_factor
      end
    end

    
    # Add the weightings to the database
    team.student_teams.each do |student_team|
      # Find existing student weighting for this assessment, or create a new one
      sw = StudentWeighting.find_or_initialize_by(student_team_id: student_team.id, assessment_id: id)
      # Do not update the weighting if it has been manually set
      unless sw.manual_set
        # Update this in the database
        sw.update_weighting(student_weights[student_team.id], num_results)
      end
    end

  end

  # Explainer methods, used when user enquires for help
  def self.whatAreAssessments()
    output = "Peer Assessments provide a structured way for students to critique and provide feedback to each other..\n"
    output += "These questions range from yes/no types, text responses and number responses, like rating something  between 0-5.\n"
    output += "Your module leaders have the option to make these questions hold a weighting."
    return output
  end

  def self.whatAreWeightings()
    output = "Weightings are useful, as they attempt to fairly redistribute grades throughout the team, depending on how everybody answered the peer assessments.\n"
    output += "This is helpful, as sometimes not everybody will end up contributing fairly\n"
    output += "So with assessments which will generate a weighting for yourself and your team mates, your grades should more accurately relate to your inputs."
    return output
  end

  def self.howToAnswerQuestions()
    output = "When you answer the peer assessments, you may find yourself struggling to accurately rate members.\n"
    output += "It is suggested that you use TeamPlayerPlus to study the team data and previous tasks, to allow yourself to give more accurate ratings."
    return output
  end


end
