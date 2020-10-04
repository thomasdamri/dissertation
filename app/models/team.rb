# == Schema Information
#
# Table name: teams
#
#  id            :bigint           not null, primary key
#  uni_module_id :bigint
#  number        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Team < ApplicationRecord

  has_many :student_teams
  has_many :users, through: :student_teams
  belongs_to :uni_module

  validates :number, presence: true, uniqueness: {scope: :uni_module}

end
