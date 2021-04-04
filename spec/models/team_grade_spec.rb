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
require 'rails_helper'

RSpec.describe TeamGrade, type: :model do
  it 'is valid with valid attributes' do
    u = create :uni_module
    t = create :team, uni_module: u
    a = create :assessment, uni_module: u

    tg = build :team_grade, team: t, assessment: a, grade: 14
    expect(tg).to be_valid
  end

  it 'is invalid with blank attributes' do
    tg = build :team_grade
    expect(tg).to_not be_valid
  end
end
