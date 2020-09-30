# == Schema Information
#
# Table name: uni_modules
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  code       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UniModule < ApplicationRecord

  has_many :teams
  has_many :assessments
  # Many staff can manage the module
  has_many :staff_modules, inverse_of: :user
  has_many :users, through: :staff_modules
  # Allows modules to add as many staff members as possible, and remove them as needed
  accepts_nested_attributes_for :staff_modules, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  def title
    code + " " + name
  end

end
