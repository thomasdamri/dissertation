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
require 'rails_helper'

RSpec.describe Assessment, type: :model do

  it 'is valid with valid attributes' do
    u = create :uni_module
    a = create(:assessment, uni_module: u)

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
    a = build(:assessment, uni_module: u)
    a.date_closed = Date.today - 14
    expect(a).to_not be_valid
    a.date_closed = Date.today + 14
    expect(a).to be_valid
  end

  it 'deletes all dependent question on deletion' do
    u = create :uni_module
    a = create :assessment, uni_module: u

    c1 = create :question, assessment: a
    c2 = create :question, assessment: a, title: 'Something else'

    expect(Question.count).to eq(2)

    a.destroy

    expect(Question.count).to eq(0)

  end

  describe '#has_team_grades?' do
    before(:each) do
      u = create :uni_module
      a = create :assessment, uni_module: u
      t = create :team, uni_module: u
    end

    it 'returns false if no team grades have been uploaded' do
      a = Assessment.first

      expect(a.has_team_grades?).to eq false

    end

    it 'returns true if team grades have been uploaded' do
      a = Assessment.first
      create :team_grade, assessment: a, team: Team.first

      expect(a.has_team_grades?).to eq true

    end

  end

  describe '#completed_by?' do
    before(:each) do
      u = create :uni_module
      a = create :assessment, uni_module: u
      t = create :team, uni_module: u
    end

    it 'only returns true if a student has completed the assessment' do
      u1 = create :user
      u2 = create :user, username: 'zzz12ab', email: 'somethingelse@gmail.com'
      t = Team.first
      st1 = create :student_team, user: u1, team: t
      st2 = create :student_team, user: u2, team: t

      a = Assessment.first

      c = create :question, assessment: a
      create :assessment_result_string ,author: st1, target: st2, question: c
      # create! :assessment_result_empty, author: st1, target: st2, question: c, value: 'Text'

      expect(a.completed_by?(st1)).to eq true
      expect(a.completed_by?(st2)).to eq false

    end

  end

  describe '#num_completed' do
    before(:each) do
      u = create :uni_module
      a = create :assessment, uni_module: u
      t = create :team, uni_module: u
    end

    it 'successfully counts the number of students who have completed the assessment' do
      a = Assessment.first
      t = Team.first

      c = create :question, assessment: a

      u1 = create :user
      u2 = create :user, username: 'zzz12ab', email: 'somethingelse@gmail.com'
      u3 = create :user, username: 'zzz12ac', email: 'somethingagain@gmail.com'

      st1 = create :student_team, user: u1, team: t
      st2 =create :student_team, user: u2, team: t
      st3 =create :student_team, user: u3, team: t


      expect(a.num_completed(t)).to eq 0

      create :assessment_result_empty, author: st1, target: st2, question: c, value: 'Text'

      expect(a.num_completed(t)).to eq 1

      # Creating another result with the same author to check it counts users, not just results
      create :assessment_result_empty, author: st1, target: st3, question: c, value: 'Text'

      expect(a.num_completed(t)).to eq 1

      create :assessment_result_empty, author: st2, target: st2, question: c, value: 'Text'
      expect(a.num_completed(t)).to eq 2

      create :assessment_result_empty, author: st3, target: st2, question: c, value: 'Text'
      expect(a.num_completed(t)).to eq 3
    end

  end

  describe '#within_fill_dates?' do
    it 'returns true when a date is inside the open and close dates' do
      a = build(:assessment, date_opened: Date.yesterday, date_closed: Date.tomorrow)
      expect(a.within_fill_dates?).to eq true
    end

    it 'returns true when a date is the open or close date' do
      a = build(:assessment, date_opened: Date.today, date_closed: Date.today)
      expect(a.within_fill_dates?).to eq true
    end

    it 'returns false when a date is outside the open or close date' do
      a = build(:assessment, date_opened: Date.yesterday - 1, date_closed: Date.yesterday)
      expect(a.within_fill_dates?).to eq false
      a2 = build(:assessment, date_opened: Date.tomorrow + 1, date_closed: Date.tomorrow + 1)
      expect(a2.within_fill_dates?).to eq false
    end
  end

  describe '#generate_weightings' do
    before(:each) do
      u = create :uni_module
      a = create :assessment, uni_module: u
      t = create :team, uni_module: u

      c1 = create :weighted_question, assessment: a, title: 'A'
      c2 = create :weighted_question, assessment: a, title: 'B'
      c3 = create :weighted_question, assessment: a, title: 'C'

      u1 = create :student
      u2 = create(:student, username: 'zzy12dp', email: 'dperry2@sheffield.ac.uk')
      u3 = create(:student, username: 'zzx12dp', email: 'dperry3@sheffield.ac.uk')
      u4 = create(:student, username: 'zzw12dp', email: 'dperry4@sheffield.ac.uk')

      st1 = create :student_team, user: u1, team: t
      st2 = create :student_team, user: u2, team: t
      st3 = create :student_team, user: u3, team: t
      st4 = create :student_team, user: u4, team: t

      # Create the assessment results

      # Each user rates themselves 10/10
      t.student_teams.each do |st|
        a.questions.each do |crit|
          create :assessment_result_empty, question: crit, author: st, target: st, value: 10
        end
      end

      # C1
      create :assessment_result_empty, question: c1, author: st1, target: st2, value: 8
      create :assessment_result_empty, question: c1, author: st1, target: st3, value: 2
      create :assessment_result_empty, question: c1, author: st1, target: st4, value: 5

      create :assessment_result_empty, question: c1, author: st2, target: st1, value: 10
      create :assessment_result_empty, question: c1, author: st2, target: st3, value: 1
      create :assessment_result_empty, question: c1, author: st2, target: st4, value: 6

      create :assessment_result_empty, question: c1, author: st3, target: st1, value: 10
      create :assessment_result_empty, question: c1, author: st3, target: st2, value: 8
      create :assessment_result_empty, question: c1, author: st3, target: st4, value: 5

      create :assessment_result_empty, question: c1, author: st4, target: st1, value: 10
      create :assessment_result_empty, question: c1, author: st4, target: st2, value: 7
      create :assessment_result_empty, question: c1, author: st4, target: st3, value: 3

      # C2
      create :assessment_result_empty, question: c2, author: st1, target: st2, value: 9
      create :assessment_result_empty, question: c2, author: st1, target: st3, value: 3
      create :assessment_result_empty, question: c2, author: st1, target: st4, value: 6

      create :assessment_result_empty, question: c2, author: st2, target: st1, value: 10
      create :assessment_result_empty, question: c2, author: st2, target: st3, value: 2
      create :assessment_result_empty, question: c2, author: st2, target: st4, value: 7

      create :assessment_result_empty, question: c2, author: st3, target: st1, value: 8
      create :assessment_result_empty, question: c2, author: st3, target: st2, value: 9
      create :assessment_result_empty, question: c2, author: st3, target: st4, value: 5

      create :assessment_result_empty, question: c2, author: st4, target: st1, value: 7
      create :assessment_result_empty, question: c2, author: st4, target: st2, value: 8
      create :assessment_result_empty, question: c2, author: st4, target: st3, value: 4

      # C3
      create :assessment_result_empty, question: c3, author: st1, target: st2, value: 7
      create :assessment_result_empty, question: c3, author: st1, target: st3, value: 4
      create :assessment_result_empty, question: c3, author: st1, target: st4, value: 7

      create :assessment_result_empty, question: c3, author: st2, target: st1, value: 9
      create :assessment_result_empty, question: c3, author: st2, target: st3, value: 3
      create :assessment_result_empty, question: c3, author: st2, target: st4, value: 8

      create :assessment_result_empty, question: c3, author: st3, target: st1, value: 9
      create :assessment_result_empty, question: c3, author: st3, target: st2, value: 10
      create :assessment_result_empty, question: c3, author: st3, target: st4, value: 6

      create :assessment_result_empty, question: c3, author: st4, target: st1, value: 10
      create :assessment_result_empty, question: c3, author: st4, target: st2, value: 8
      create :assessment_result_empty, question: c3, author: st4, target: st3, value: 5

    end

    it 'gives all students a weighting of 1 if no assessment results exist' do
      a = Assessment.first
      t = Team.first

      # It's better to delete all assessment results here, in order to preserve the before :each section above
      a.assessment_results.each do |res|
        res.destroy
      end

      a.generate_weightings(t)

      t.student_teams.each do |st|
        sw = StudentWeighting.where(student_team: st, assessment: a).first
        expect(sw.weighting).to eq 1
      end


    end

    it 'generates weightings based on assessment results and does not reset manual weightings' do
      a = Assessment.first
      t = Team.first

      a.generate_weightings(t)

      u1 = User.where(username: 'zzz12dp').first
      u2 = User.where(username: 'zzy12dp').first
      u3 = User.where(username: 'zzx12dp').first
      u4 = User.where(username: 'zzw12dp').first

      st1 = StudentTeam.where(user: u1).first
      st2 = StudentTeam.where(user: u2).first
      st3 = StudentTeam.where(user: u3).first
      st4 = StudentTeam.where(user: u4).first

      # I got these expected weightings by doing the algorithm by hand
      sw = StudentWeighting.where(student_team: st1, assessment: a).first
      expect(sw.weighting.round(2)).to eq 1.27

      sw = StudentWeighting.where(student_team: st2, assessment: a).first
      expect(sw.weighting.round(2)).to eq 1.17

      sw = StudentWeighting.where(student_team: st3, assessment: a).first
      expect(sw.weighting.round(2)).to eq 0.61

      sw = StudentWeighting.where(student_team: st4, assessment: a).first
      expect(sw.weighting.round(2)).to eq 0.95

      # Set last sw to be manually set
      sw.manual_update(1.2, "Some reason")

      expect(sw.weighting).to eq 1.2

      a.generate_weightings(t)

      expect(sw.weighting).to eq 1.2

    end

    it 'generates weightings correctly when question have different weightings' do
      a = Assessment.first
      t = Team.first

      # Load in all question and users from the database
      crits = a.questions.all
      c1 = crits[0]

      # Give the first question twice the weight of the others
      c1.weighting = 2
      c1.save

      u1 = User.where(username: 'zzz12dp').first
      u2 = User.where(username: 'zzy12dp').first
      u3 = User.where(username: 'zzx12dp').first
      u4 = User.where(username: 'zzw12dp').first

      st1 = StudentTeam.where(user: u1).first
      st2 = StudentTeam.where(user: u2).first
      st3 = StudentTeam.where(user: u3).first
      st4 = StudentTeam.where(user: u4).first

      a.generate_weightings(t)

      # I got these expected weightings by doing the algorithm by hand
      sw = StudentWeighting.where(student_team: st1, assessment: a).first
      expect(sw.weighting.round(2)).to eq 1.30

      sw = StudentWeighting.where(student_team: st2, assessment: a).first
      expect(sw.weighting.round(2)).to eq 1.16

      sw = StudentWeighting.where(student_team: st3, assessment: a).first
      expect(sw.weighting.round(2)).to eq 0.59

      sw = StudentWeighting.where(student_team: st4, assessment: a).first
      expect(sw.weighting.round(2)).to eq 0.94

    end

    it 'generates weightings correctly if some team members have not yet filled in the assessment' do
      a = Assessment.first
      t = Team.first

      # Load in all question and users from the database
      crits = a.questions.all
      c1 = crits[0]

      u1 = User.where(username: 'zzz12dp').first
      u2 = User.where(username: 'zzy12dp').first
      u3 = User.where(username: 'zzx12dp').first
      u4 = User.where(username: 'zzw12dp').first

      st1 = StudentTeam.where(user: u1).first
      st2 = StudentTeam.where(user: u2).first
      st3 = StudentTeam.where(user: u3).first
      st4 = StudentTeam.where(user: u4).first

      # Destroy all of user 3's authored results - they did not fill the form in
      a.assessment_results.where(author: st3).each do |res|
        res.destroy
      end

      a.generate_weightings(t)

      # I got these expected weightings by doing the algorithm by hand
      sw = StudentWeighting.where(student_team: st1, assessment: a).first
      expect(sw.weighting.round(2)).to eq 1.33

      sw = StudentWeighting.where(student_team: st2, assessment: a).first
      expect(sw.weighting.round(2)).to eq 1.19

      sw = StudentWeighting.where(student_team: st3, assessment: a).first
      expect(sw.weighting.round(2)).to eq 0.42

      sw = StudentWeighting.where(student_team: st4, assessment: a).first
      expect(sw.weighting.round(2)).to eq 1.06
    end

  end

end
