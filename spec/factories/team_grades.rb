# == Schema Information
#
# Table name: team_grades
#
#  id            :bigint           not null, primary key
#  team_id       :bigint
#  assessment_id :bigint
#  grade         :float(24)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :team_grade do
    
  end
end
