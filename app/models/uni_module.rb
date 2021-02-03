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
  has_many :users, through: :staff_modules
  # Allows modules to add as many staff members as possible, and remove them as needed
  accepts_nested_attributes_for :staff_modules, reject_if: :all_blank, allow_destroy: true

  # Many students will submit many worklogs for this module
  has_many :worklogs, dependent: :destroy

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

  # Returns true if the team specified has worklogs for the week specified
  def has_worklogs?(team, week)

  end

  # Returns true if the user given has filled in a worklog for the current week
  def has_filled_in_log?(user, date)
    Worklog.where(author: user, uni_module: self, fill_date: date).first.nil? ? false : true
  end

end
