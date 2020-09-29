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
  has_many :staff_modules

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  def title
    code + " " + name
  end

end
