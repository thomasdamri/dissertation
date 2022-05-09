require 'rails_helper'

RSpec.describe StudentChat, type: :model do

  it 'validates task objective length' do 
    u = create :uni_module
    t = create :team, uni_module: u 
    u1 = create :user, username: 'test1', email: 'test1@gmail.com'
    st1 = create :student_team, user: u1, team: t
    valid_task = build :student_task_one, student_team: st1
    invalid_task = build :empty_task, student_team: st1
    expect(valid_task).to be_valid 
    expect(invalid_task).to_not be_valid
  end

  it 'difficulty int to string conversions' do 
    expect(StudentTask.difficulty_int_to_string(0)).to eq "Easy"
    expect(StudentTask.difficulty_int_to_string(1)).to eq "Medium"
    expect(StudentTask.difficulty_int_to_string(2)).to eq "Hard"
    expect(StudentTask.difficulty_int_to_string(223312321)).to eq "Medium"
    expect(StudentTask.difficulty_string_to_int("Easy")).to eq 0
    expect(StudentTask.difficulty_string_to_int("Medium")).to eq 1
    expect(StudentTask.difficulty_string_to_int("Hard")).to eq 2
    expect(StudentTask.difficulty_string_to_int("RANDOM")).to eq 1
    expect(StudentTask.difficulty_int_to_style(0)).to eq "border-bottom: 7px solid green;"
    expect(StudentTask.difficulty_int_to_style(1)).to eq "border-bottom: 7px solid yellow;"
    expect(StudentTask.difficulty_int_to_style(2)).to eq "border-bottom: 7px solid red;"
    expect(StudentTask.difficulty_int_to_style(223312321)).to eq "border-bottom: 7px solid yellow;"

  end


  describe "#get_linked_students" do
    specify "only one student" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com', display_name: "Ted"
      st1 = create :student_team, user: u1, team: t
      st1task1 = create :student_task_one, student_team: st1 
      expect(st1task1.get_linked_students()).to eq "Ted"
    end
  end

  describe "#hide_task" do
    specify "does it hide task" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com', display_name: "Ted"
      st1 = create :student_team, user: u1, team: t
      st1task1 = create :student_task_one, student_team: st1 
      expect(st1task1.hidden).to eq false
      StudentTask.hide_task(st1task1.id)
      hidden = StudentTask.last
      expect(hidden.hidden).to eq true
    end
  end

  describe '#whatAreTeamTasks' do
    it 'returns string correctly' do
      string = StudentTask.whatAreTeamTasks()
      expect(string.first).to eq 'S'
      expect(string.last).to eq '.'
    end 
  end

  describe '#difficultyExplained' do
    it 'returns string correctly' do
      string = StudentTask.difficultyExplained()
      expect(string.first).to eq 'S'
      expect(string.last).to eq '.'
    end 
  end

  describe '#commendationsExplained' do
    it 'returns string correctly' do
      string = StudentTask.commendationsExplained()
      expect(string.first).to eq 'T'
      expect(string.last).to eq '.'
    end 
  end

  describe '#taskCompletingExplained' do
    it 'returns string correctly' do
      string = StudentTask.taskCompletingExplained()
      expect(string.first).to eq 'O'
      expect(string.last).to eq '.'
    end 
  end



end 



  