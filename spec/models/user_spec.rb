# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  email              :string(255)      default(""), not null
#  sign_in_count      :integer          default(0), not null
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :string(255)
#  last_sign_in_ip    :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  username           :string(255)
#  uid                :string(255)
#  mail               :string(255)
#  ou                 :string(255)
#  dn                 :string(255)
#  sn                 :string(255)
#  givenname          :string(255)
#  display_name       :string(255)
#  reg_no             :integer
#  staff              :boolean
#  admin              :boolean
#
require 'rails_helper'
require "cancan/matchers"

RSpec.describe User, type: :model do

  it 'is valid with a username, email address, and staff + admin booleans' do
    u = build(:user)
    expect(u).to be_valid
  end

  it 'is invalid with blank attributes' do
    u = build(:blank_user)
    expect(u).to_not be_valid
  end

  it 'is invalid with a non-unique username or email address' do
    u1 = create(:user)
    expect(u1).to be_valid

    u2 = build(:user)
    expect(u2).to_not be_valid

    u2.username = 'zzy12dp'
    expect(u2).to_not be_valid

    u2.email = "dperry2@sheffield.ac.uk"
    expect(u2).to be_valid

  end

  it 'is invalid with an invalid email address' do
    u = build(:user, email: 'fjeiwvn')
    expect(u).to_not be_valid
  end

  it 'is invalid with a display_name that is too long' do
    u = build :user, display_name: "a" * User.max_display_name_length
    expect(u).to be_valid
    u.display_name = "a" * (User.max_display_name_length + 1)
    expect(u).to_not be_valid
  end

  describe '#real_display_name' do
    specify "It returns the correct values" do
      u = create :user, givenname: "", sn: "", display_name: ""
      expect(u.real_display_name).to eq "Name not found"

      u.givenname = "John"
      u.sn = "Smith"
      u.save
      expect(u.real_display_name).to eq "John Smith"

      u.display_name = "Bob Johnson"
      u.save
      expect(u.real_display_name).to eq "Bob Johnson"
    end
  end

  describe 'abilities' do 
    specify "Admin user " do 
      ability = Ability.new(create :user, username: 'test1', email: 'test1@gmail.com', admin: true)
      expect(ability).to be_able_to(:manage, :all)
    end
    specify "Staff user " do 
      staff = create :user, username: 'test1', email: 'test1@gmail.com', staff: true
      ability = Ability.new(staff)
      expect(ability).to be_able_to([:read, :show_all_staff, :new, :create], UniModule)

      #Check to see if staff members can manage uni module
      u = create :uni_module
      staff_module = create :staff_module, user: staff, uni_module: u
      staff_non_module_user = create :user, username: 'test2', email: 'test2@gmail.com', staff: true
      ability2 = Ability.new(staff_non_module_user)
      expect(ability).to be_able_to(:manage, u)
      expect(ability2).to_not be_able_to(:manage, u)


      #Check to see if staff members have abilities for student tasks created for a module
      t = create :team, uni_module: u
      u1 = create :user, username: 'test3', email: 'test3@gmail.com', display_name: "Ted"
      st1 = create :student_team, user: u1, team: t
      st1task1 = create :student_task_one, student_team: st1 

      expect(ability).to be_able_to([:show_student_task, :comment, :like_task, :return_task_list], st1task1)
      expect(ability2).to_not be_able_to([:show_student_task, :comment, :like_task, :return_task_list], st1task1)

      #Check to see if staff members have abilities for student reports created for a module
      report = create :student_report_type_0, student_team: st1

      expect(ability).to be_able_to([:show_report, :report_resolution, :show_complete_report, :complete_report, :complete_report_form], report)
      expect(ability2).to_not be_able_to([:show_report, :report_resolution, :show_complete_report, :complete_report, :complete_report_form], report)
      
      #Check to see if staff members can manage student team abilites
      expect(ability).to be_able_to([:manage], st1)
      expect(ability2).to_not be_able_to([:manage], st1)

      #Check to see if staff members can manage team abilites
      expect(ability).to be_able_to([:manage], t)
      expect(ability2).to_not be_able_to([:manage], t)

      #Check to see staff members assessment abilites
      a = create :assessment, uni_module: u
      expect(ability).to be_able_to([:manage], a)
      expect(ability2).to_not be_able_to([:manage], a)
      expect(ability).to_not be_able_to([:fill_in, :process_assess], a)
      expect(ability2).to_not be_able_to([:fill_in, :process_assess], a)

      #Check to see staff members student weighting abilites
      sw = create(:student_weighting, student_team: st1, assessment: a)
      expect(ability).to be_able_to([:manage], sw)
      expect(ability2).to_not be_able_to([:manage], sw)
    end

    specify "checking student user abilities " do 
      student = create :user, username: 'test1', email: 'test1@gmail.com'
      u = create :uni_module
      t = create :team, uni_module: u
      student_team1 = create :student_team, user: student, team: t
      ability = Ability.new(student)
      student2 = create :user, username: 'test2', email: 'test2@gmail.com'
      student_team2 = create :student_team, user: student2, team: t
      ability2 = Ability.new(student2)
    
      # non_team_student = create :user, username: 'test3', email: 'test3@gmail.com'
      # ability3 = Ability.new(non_team_student)
    
    
      #Check to see if students can manage their own team profile
      expect(ability).to be_able_to(:manage, student_team1)
      expect(ability2).to_not be_able_to(:manage, student_team1)
    
      # #Students can only manage their own chats
      # chat = create :student_chat_one, student_team: student_team_1
      # expect(ability).to be_able_to(:manage, chat)
      # expect(ability2).to_not be_able_to(:manage, chat)
    
      # #Anyone can create a student task
      # expect(ability).to be_able_to(:create, StudentTask)
      # expect(ability2).to be_able_to(:create, StudentTask)
    
      # #Anyone apart of the team have a few task abilities for team members tasks
      # student_task = create :student_task_one, student_team: student_team1
      # expect(ability).to be_able_to([show_student_task, :comment, :like_task], student_task)
      # expect(ability2).to be_able_to([:show_student_task, :comment, :like_task], student_task)
      # expect(ability3).to_not be_able_to([show_student_task, :comment, :like_task], chat)
    end
  end 


end

