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
require 'rails_helper'

RSpec.describe UniModule, type: :model do
  it 'is valid with a name and code' do
    mod = build(:uni_module)
    expect(mod).to be_valid
  end

  it 'is invalid with empty attributes' do
    mod = build(:empty_uni_module)
    expect(mod).to_not be_valid
  end

  it 'is invalid with a non-unique name or code' do
    m1 = create(:uni_module)
    expect(m1).to be_valid

    m2 = build(:uni_module)
    expect(m2).to_not be_valid

    m2.name = "Something else"
    expect(m2).to_not be_valid

    m2.code = "ZZZ9999"
    expect(m2).to be_valid
  end

  it 'is invalid with an end date after the start date' do
    m = build :uni_module, start_date: Date.today, end_date: Date.yesterday
    expect(m).to_not be_valid
    m.end_date = Date.today
    expect(m).to be_valid
    m.end_date = Date.today + 1
    expect(m).to be_valid
  end


  describe '#title' do
    it 'return the title' do
      u = create :uni_module
      expect(u.title).to eq ('TST1001 Test Module')
    end
  end

  describe '#ensure_mondays' do
    it 'module starts and ends on a monday' do
      u = create :start_and_finish_monday_uni_module
      expect(u.start_date.monday?).to eq true 
      expect(u.end_date.monday?).to eq true 
      u.ensure_mondays
      expect(u.start_date.monday?).to eq true 
      expect(u.end_date.monday?).to eq true 
    end

    it 'module does not start or finish on a monday' do
      u = create :no_monday_uni_module
      expect(u.start_date.monday?).to eq false 
      expect(u.end_date.monday?).to eq false 
      u.ensure_mondays
      expect(u.start_date.monday?).to eq true 
      expect(u.end_date.monday?).to eq true 
    end
  end

  describe '#get_week_range' do
    it 'module not finished yet' do
      u = create :uni_module
      range = u.get_week_range 
      expect(range === Date.today).to eq true
    end

    it 'module already finished' do
      u = create :uni_module
      u.end_date = Date.today - 10
      range = u.get_week_range 
      expect(range === Date.today).to eq false
    end
  end

  describe '#createWeekNumToDatesMap' do
    it 'on week 2' do
      u = create :on_week_2_uni_module
      hash = u.createWeekNumToDatesMap
      #Need to check for 2 or 3, because the system will add some days if course doesn't start on a monday
      expect(hash.size).to eq(2).or eq(3)
      expect(hash.keys.first).to eq ("Current Week")
    end

    it 'on week 0' do
      u = create :week_0_uni_module
      hash = u.createWeekNumToDatesMap
      expect(hash.size).to eq(1)
      expect(hash.keys.first).to eq ("Current Week")
    end
  end

  describe '#getUncompletedOutgoingAssessmentCount' do
    before(:each) do
      u = create :uni_module
      t = create :team, uni_module: u
      u1 = create(:student, username: 'test1', email: 'test1@sheffield.ac.uk')
      st1 = create :student_team, user: u1, team: t
      u2 = create(:student, username: 'test2', email: 'test2@sheffield.ac.uk')
      st2 = create :student_team, user: u2, team: t
      a = create :assessment, uni_module: u
      q = create :weighted_question, assessment: a, title: 'C'
    end

    it 'user has filled all assessments' do
      a = Assessment.first 
      u = UniModule.first
      u1 = User.where(username: "test1").first
      u2 = User.where(username: "test2").first
      create :assessment_result_int ,author: u1.student_teams.first, target: u2.student_teams.first, question: a.questions.first
      expect(u.getUncompletedOutgoingAssessmentCount(u1.student_teams.first)).to eq(0)
    end

    it 'user has not completed it but the assessment still open' do
      u = UniModule.first
      u1 = User.where(username: "test1").first
      expect(u.getUncompletedOutgoingAssessmentCount(u1.student_teams.first)).to eq(1)
    end

    it 'user has not completed it but the assessment closed' do
      u = UniModule.first
      u1 = User.where(username: "test1").first
      u2 = User.where(username: "test2").first
      a = Assessment.first 
      create :assessment_result_int ,author: u1.student_teams.first, target: u2.student_teams.first, question: a.questions.first
      a = create :closed_assessment, uni_module: u
      expect(u.getUncompletedOutgoingAssessmentCount(u1.student_teams.first)).to eq(0)
    end

  end

end