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
require 'rails_helper'

RSpec.describe Assessment, type: :model do

  it 'is valid with valid attributes' do
    u = create :uni_module
    a = build :assessment
    a.uni_module = u
    expect(a).to be_valid
  end

  it 'is invalid with blank attributes' do
    a = build :blank_assessment
    expect(a).to_not be_valid
  end

  it 'is invalid with a non-unique name for its module' do
    u = create :uni_module
    a = create :assessment, uni_module: u
    a2 = build :assessment, uni_module: u

    expect(a).to be_valid
    expect(a2).to_not be_valid

    a2.name = "Something different"

    expect(a).to be_valid
    expect(a2).to be_valid
  end

  it 'is invalid with a close date before its opening date' do
    u = create :uni_module
    a = build :assessment
    a.uni_module = u
    a.date_closed = Date.new 2020, 9, 12
    expect(a).to_not be_valid
  end

  it 'deletes all dependent criteria on deletion' do
    u = create :uni_module
    a = create :assessment, uni_module: u

    c1 = create :criterium, assessment: a
    c2 = create :criterium, assessment: a, title: 'Something else', order: 2

    expect(Criterium.count).to eq(2)

    a.destroy

    expect(Criterium.count).to eq(0)

  end

  describe '#generate_weightings' do
    before(:each) do
      u = create :uni_module
      a = create :assessment, uni_module: u
      t = create :team, uni_module: u

      c1 = create :weighted_criterium, assessment: a, title: 'A', order: 1
      c2 = create :weighted_criterium, assessment: a, title: 'B', order: 2
      c3 = create :weighted_criterium, assessment: a, title: 'C', order: 3

      u1 = create :student
      u2 = create(:student, username: 'zzy12dp', email: 'dperry2@sheffield.ac.uk')
      u3 = create(:student, username: 'zzx12dp', email: 'dperry3@sheffield.ac.uk')
      u4 = create(:student, username: 'zzw12dp', email: 'dperry4@sheffield.ac.uk')

      create :student_team, user: u1, team: t
      create :student_team, user: u2, team: t
      create :student_team, user: u3, team: t
      create :student_team, user: u4, team: t
    end

    it 'gives all students a weighting of 1 if no assessment results exist' do
      a = Assessment.first
      t = Team.first

      a.generate_weightings(t)

      t.users.each do |user|
        sw = StudentWeighting.where(user: user, assessment: a).first
        expect(sw.weighting).to eq 1
      end


    end

    it 'generates weightings based on assessment results' do
      a = Assessment.first
      t = Team.first

      t.users.each do |user|
        a.criteria.each do |crit|
          create :assessment_result, criterium: crit, author: user, target: user, value: 10
        end
      end

      c1 = a.criteria.where(order: 1).first
      c2 = a.criteria.where(order: 2).first
      c3 = a.criteria.where(order: 3).first

      u1 = User.where(username: 'zzz12dp').first
      u2 = User.where(username: 'zzy12dp').first
      u3 = User.where(username: 'zzx12dp').first
      u4 = User.where(username: 'zzw12dp').first

      # C1
      create :assessment_result, criterium: c1, author: u1, target: u2, value: 8
      create :assessment_result, criterium: c1, author: u1, target: u3, value: 2
      create :assessment_result, criterium: c1, author: u1, target: u4, value: 5

      create :assessment_result, criterium: c1, author: u2, target: u1, value: 10
      create :assessment_result, criterium: c1, author: u2, target: u3, value: 1
      create :assessment_result, criterium: c1, author: u2, target: u4, value: 6

      create :assessment_result, criterium: c1, author: u3, target: u1, value: 10
      create :assessment_result, criterium: c1, author: u3, target: u2, value: 8
      create :assessment_result, criterium: c1, author: u3, target: u4, value: 5

      create :assessment_result, criterium: c1, author: u4, target: u1, value: 10
      create :assessment_result, criterium: c1, author: u4, target: u2, value: 7
      create :assessment_result, criterium: c1, author: u4, target: u3, value: 3

      # C2
      create :assessment_result, criterium: c2, author: u1, target: u2, value: 9
      create :assessment_result, criterium: c2, author: u1, target: u3, value: 3
      create :assessment_result, criterium: c2, author: u1, target: u4, value: 6

      create :assessment_result, criterium: c2, author: u2, target: u1, value: 10
      create :assessment_result, criterium: c2, author: u2, target: u3, value: 2
      create :assessment_result, criterium: c2, author: u2, target: u4, value: 7

      create :assessment_result, criterium: c2, author: u3, target: u1, value: 8
      create :assessment_result, criterium: c2, author: u3, target: u2, value: 9
      create :assessment_result, criterium: c2, author: u3, target: u4, value: 5

      create :assessment_result, criterium: c2, author: u4, target: u1, value: 7
      create :assessment_result, criterium: c2, author: u4, target: u2, value: 8
      create :assessment_result, criterium: c2, author: u4, target: u3, value: 4
      
      # C3
      create :assessment_result, criterium: c3, author: u1, target: u2, value: 7
      create :assessment_result, criterium: c3, author: u1, target: u3, value: 4
      create :assessment_result, criterium: c3, author: u1, target: u4, value: 7

      create :assessment_result, criterium: c3, author: u2, target: u1, value: 9
      create :assessment_result, criterium: c3, author: u2, target: u3, value: 3
      create :assessment_result, criterium: c3, author: u2, target: u4, value: 8

      create :assessment_result, criterium: c3, author: u3, target: u1, value: 9
      create :assessment_result, criterium: c3, author: u3, target: u2, value: 10
      create :assessment_result, criterium: c3, author: u3, target: u4, value: 6

      create :assessment_result, criterium: c3, author: u4, target: u1, value: 10
      create :assessment_result, criterium: c3, author: u4, target: u2, value: 8
      create :assessment_result, criterium: c3, author: u4, target: u3, value: 5

      a.generate_weightings(t)

      sw = StudentWeighting.where(user: u1, assessment: a).first
      expect(sw.weighting.round(2)).to eq 1.26

      sw = StudentWeighting.where(user: u2, assessment: a).first
      expect(sw.weighting.round(2)).to eq 1.16

      sw = StudentWeighting.where(user: u3, assessment: a).first
      expect(sw.weighting.round(2)).to eq 0.64

      sw = StudentWeighting.where(user: u4, assessment: a).first
      expect(sw.weighting.round(2)).to eq 0.95

    end

  end

end
