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
require 'rails_helper'

RSpec.describe User, type: :model do

  it 'is valid with a number' do
    u = create(:uni_module)

    t = build(:team, uni_module: u)
    expect(t).to be_valid
  end

  it 'is invalid without a number or module' do
    t = build(:blank_team)
    expect(t).to_not be_valid
  end

  it 'is invalid with a number shared with another team of the same module' do
    u = create(:uni_module)

    t1 = create(:team, uni_module: u)

    t2 = build(:team, uni_module: u)
    expect(t2).to_not be_valid

    t2.team_number = 2
    expect(t2).to be_valid

  end

  describe '#group_email_link' do
    before(:each) do
      u = create :uni_module
      t = create :team, uni_module: u
    end

    it 'empty group' do
      t = Team.first
      t.group_email_link
      expect(t.group_email_link).to eq ""
    end

    it 'single person group' do
      t = Team.first
      u1 = create(:student, username: 'test1', email: 'test1@sheffield.ac.uk')
      st1 = create :student_team, user: u1, team: t
      
      t.group_email_link
      expect(t.group_email_link).to eq "test1@sheffield.ac.uk"
    end

    it 'multi group' do
      t = Team.first
      u1 = create(:student, username: 'test1', email: 'test1@sheffield.ac.uk')
      st1 = create :student_team, user: u1, team: t
      u1 = create(:student, username: 'test2', email: 'test2@sheffield.ac.uk')
      st1 = create :student_team, user: u1, team: t
      
      t.group_email_link
      expect(t.group_email_link).to eq "test1@sheffield.ac.uk,test2@sheffield.ac.uk"
    end
  end

  describe '#get_week_chats' do
    before(:each) do
      u = create :uni_module
      t = create :team, uni_module: u
      u1 = create(:student, username: 'test1', email: 'test1@sheffield.ac.uk')
      st1 = create :student_team, user: u1, team: t
      u2 = create(:student, username: 'test2', email: 'test2@sheffield.ac.uk')
      st2 = create :student_team, user: u2, team: t
    end

    it 'get team chats week 0' do
      t = Team.first
      u1 = User.where(username: 'test1').first
      u2 = User.where(username: 'test2').first
      create :student_chat_one, student_team: u1.student_teams.first
      create :student_chat_two, student_team: u2.student_teams.first

      expect(t.get_week_chats(-1, DateTime.now).size).to eq 2
    end

    it 'get team chats week 1' do
      t = Team.first
      u1 = User.where(username: 'test1').first
      u2 = User.where(username: 'test2').first
      create :student_chat_one, student_team: u1.student_teams.first
      create :student_chat_two, student_team: u2.student_teams.first

      expect(t.get_week_chats(-1, (DateTime.now+(8.days))).size).to eq 0
    end

    it 'get team chats week 0 no messages' do
      t = Team.first
      expect(t.get_week_chats(-1, DateTime.now).size).to eq 0
    end

    it 'get student 1 chats week 0' do
      t = Team.first
      u1 = User.where(username: 'test1').first
      u2 = User.where(username: 'test2').first
      create :student_chat_one, student_team: u1.student_teams.first
      create :student_chat_two, student_team: u2.student_teams.first

      expect(t.get_week_chats(u1.student_teams.first.id, DateTime.now).size).to eq 1
    end

    it 'get student 1 chats week 0 no messages' do
      t = Team.first
      u1 = User.where(username: 'test1').first
      u2 = User.where(username: 'test2').first
      create :student_chat_two, student_team: u2.student_teams.first

      expect(t.get_week_chats(u1.student_teams.first.id, DateTime.now).size).to eq 0
    end
  end

end
