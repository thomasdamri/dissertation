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
  has_many :worklogs

  # Each module must have a unique name and code
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  # Each module must have a start and end date
  validates :start_date, presence: true
  validates :end_date, presence: true

  # Additonal validations for checking dates
  validates_with UniModuleValidator

  def title
    code + " " + name
  end

end
