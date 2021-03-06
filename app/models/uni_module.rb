# == Schema Information
#
# Table name: uni_modules
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  code       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  start_date :date
#  end_date   :date
#
class UniModule < ApplicationRecord

  has_many :teams, dependent: :destroy
  has_many :assessments, dependent: :destroy
  # Many staff can manage the module
  has_many :staff_modules, inverse_of: :uni_module, dependent: :destroy
  #has_many :users, through: :staff_modules
  # Allows modules to add as many staff members as possible, and remove them as needed
  accepts_nested_attributes_for :staff_modules, reject_if: :all_blank, allow_destroy: true



  has_many :student_teams, through: :teams

  # Each module must have a unique name and code
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  # Each module must have a start and end date
  validates :start_date, presence: true
  validates :end_date, presence: true

  # Additional validations for checking dates
  validates_with UniModuleValidator

  def title
    code + " " + name
  end

  # Ensures start_date and end_date are mondays, so they mark the beginning of the week where logs start/end
  def ensure_mondays
    unless self.start_date.nil? or self.end_date.nil?
      # Don't set it to previous monday if already a monday
      unless self.start_date.monday?
        self.start_date = self.start_date.prev_occurring(:monday)
      end
      unless self.end_date.monday?
        self.end_date = self.end_date.prev_occurring(:monday)
      end
      save
    end
  end




  def get_week_range()
    start_date = self.start_date
    if(Date.today<self.end_date)
      end_date = Date.today
    else
      end_date = self.end_date
    end
    range = start_date..end_date
    return range
  end

  def createWeekNumToDatesMap()
    week_hash = {}
    range = self.get_week_range()
    range.step(7) { |x| week_hash["Week "+week_hash.count.to_s] = x.to_s}
    week_hash["Current Week"] = week_hash.delete week_hash.keys.last
    reversed_hash = Hash[week_hash.to_a.reverse]
    return reversed_hash
  end

  def getUncompletedOutgoingAssessmentCount(student_team)
    num_outgoing = 0
    assessments.each do |assessment|
      if (assessment.within_fill_dates? && !(assessment.completed_by? student_team))
        num_outgoing += 1
      end
    end
    return num_outgoing
  end

end
