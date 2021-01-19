require "rails_helper"
require "cancan/matchers"

describe "Uploading team assignments" do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
  end

  specify "As a staff member on a module I can upload a file assigning students to teams", js: true do
    # Create users to test assignment on
    create :user, staff: false, username: "zzx12tu", email: "a@gmail.com"
    create :user, staff: false, username: "zzy12tu", email: "s@gmail.com"
    create :user, staff: false, username: "zzz12tu", email: "d@gmail.com"
    create :user, staff: false, username: "zzw12tu", email: "f@gmail.com"
    create :user, staff: false, username: "zzv12tu", email: "h@gmail.com"
    create :user, staff: false, username: "zzm12tu", email: "j@gmail.com"

    mod = UniModule.first

    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    expect(ability).to be_able_to :upload_teams, mod
    expect(ability).to be_able_to :team_process, mod

    visit "/uni_modules/#{mod.id}"
    click_link "Upload Team Assignment"
    attach_file "spec/uploads/teams.csv"
    click_button "Import"

    # Page should have the remove button now
    expect(page).to have_content "Remove Current Team Assignment"
    expect(page).to have_content "Number of teams: 2"
  end

  specify "If no file is selected the user is prompted to select one", js: true do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    mod = UniModule.first

    visit "/uni_modules/#{mod.id}"
    click_link "Upload Team Assignment"
    click_button "Import"

    expect(page).to have_content "Upload failed. Please attach a file before attempting upload"
  end

  specify "As a staff member not associated with the module, I cannot upload a team assignment" do
    mod = UniModule.first
    other_staff = create :user, staff: true, username: "zzz12ll", email: "w@gmail.com"
    ability = Ability.new(other_staff)
    expect(ability).to_not be_able_to :upload_teams, mod
    expect(ability).to_not be_able_to :team_process, mod

    # Cannot see the team assignment card
    visit "/uni_modules/#{mod.id}"

    expect(page).to_not have_content "Team Assignments"
  end

  specify "As a student I cannot upload a team assignment" do
    mod = UniModule.first
    student = create :user, staff: false, username: "zzz12qq", email: "s@gmail.com"
    ability = Ability.new(student)
    expect(ability).to_not be_able_to :upload_teams, mod
    expect(ability).to_not be_able_to :team_process, mod
  end
end

describe "Removing a team assignment" do
  before(:each) do
    staff = create :user, staff: true

    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
  end

  specify "As a staff member on a module I can remove an existing team assignment" do
    mod = UniModule.first
    t1 = create :team, uni_module: mod
    t2 = create :team, uni_module: mod, number: 2

    u1 = create :user, staff: false, username: "zzx12tu", email: "a@gmail.com"
    u2 = create :user, staff: false, username: "zzy12tu", email: "s@gmail.com"
    u3 = create :user, staff: false, username: "zzz12tu", email: "d@gmail.com"
    u4 = create :user, staff: false, username: "zzw12tu", email: "f@gmail.com"
    u5 = create :user, staff: false, username: "zzv12tu", email: "h@gmail.com"
    u6 = create :user, staff: false, username: "zzm12tu", email: "j@gmail.com"

    create :student_team, user: u1, team: t1
    create :student_team, user: u2, team: t1
    create :student_team, user: u3, team: t1
    create :student_team, user: u4, team: t2
    create :student_team, user: u5, team: t2
    create :student_team, user: u6, team: t2

    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    expect(ability).to be_able_to :delete_teams, mod

    visit "/uni_modules/#{mod.id}"
    expect(page).to have_content "Number of teams: 2"
    click_link "Remove Current Team Assignment"

    expect(page).to have_content "Number of teams: 0"
  end

  specify "As a staff member not associated with a module I cannot remove a team assignment" do
    mod = UniModule.first
    other_staff = create :user, staff: true, username: "zzz12er", email: "l@gmail.com"
    ability = Ability.new(other_staff)
    expect(ability).to_not be_able_to :delete_teams, mod
  end

  specify "As a student I cannot remove a team assignment" do
    student = User.where(username: 'zzx12tu').first
    ability = Ability.new(student)
    mod = UniModule.first
    expect(ability).to_not be_able_to :delete_teams, mod
  end
end

describe 'Viewing team pages' do
  before(:each) do
    staff = create :user, staff: true

    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    create :assessment, uni_module: mod

    t = create :team, uni_module: mod

    u1 = create :user, username: 'zzz12ac', email: '1@gmail.com', staff: false
    u2 = create :user, username: 'zzz12ad', email: '2@gmail.com', staff: false
    u3 = create :user, username: 'zzz12ae', email: '3@gmail.com', staff: false
    u4 = create :user, username: 'zzz12af', email: '4@gmail.com', staff: false

    create :student_team, team: t, user: u1
    create :student_team, team: t, user: u2
    create :student_team, team: t, user: u3
    create :student_team, team: t, user: u4
  end
  # This test does all permissions checks in one test to save time from constantly having to recreate the db
  specify 'I can only view a team page if I am authorised' do
    t = Team.first
    mod = UniModule.first

    staff = User.where(staff: true).first
    other_staff = create :user, username: 'zzz12ag', email: '5@gmail.com', staff: true

    ability = Ability.new(staff)
    login_as staff, scope: :user

    # Staff member can access the team page for the module they are associated with
    expect(ability).to be_able_to :read, t
    visit "/teams/#{t.id}"
    # Staff can see the staff assessment table (cannot see option to fill in assessment)
    expect(page).to_not have_selector '#studentAssessTable'
    expect(page).to have_selector '#staffAssessTable'

    # Staff cannot access the team page for other modules
    login_as other_staff, scope: :user
    ability = Ability.new(other_staff)
    expect(ability).to_not be_able_to :read, t

    # Students can access their own team page
    student = t.users.first
    login_as student, scope: :user
    ability = Ability.new(student)
    expect(ability).to be_able_to :read, t
    # Students can only see the student assessment table (cannot see options for manipulating grades)
    visit "/teams/#{t.id}"
    expect(page).to have_selector '#studentAssessTable'
    expect(page).to_not have_selector '#staffAssessTable'

    t2 = create :team, uni_module: mod, number: 2

    u5 = create :user, username: 'zzz12ah', email: '6@gmail.com', staff: false
    u6 = create :user, username: 'zzz12ai', email: '7@gmail.com', staff: false
    u7 = create :user, username: 'zzz12aj', email: '8@gmail.com', staff: false
    u8 = create :user, username: 'zzz12ak', email: '9@gmail.com', staff: false

    create :student_team, team: t2, user: u5
    create :student_team, team: t2, user: u6
    create :student_team, team: t2, user: u7
    create :student_team, team: t2, user: u8

    # Students cannot access a different team's page on the same module
    expect(ability).to_not be_able_to :read, t2

    mod2 = create :uni_module, name: "Something else", code: "TEST2001"

    t3 = create :team, uni_module: mod2

    u9 = create :user, username: 'zzz12al', email: '10@gmail.com', staff: false
    u10 = create :user, username: 'zzz12am', email: '11@gmail.com', staff: false
    u11 = create :user, username: 'zzz12an', email: '12@gmail.com', staff: false
    u12 = create :user, username: 'zzz12ao', email: '13@gmail.com', staff: false

    create :student_team, team: t3, user: u9
    create :student_team, team: t3, user: u10
    create :student_team, team: t3, user: u11
    create :student_team, team: t3, user: u12

    # Students cannot access a different module's team pages
    expect(ability).to_not be_able_to :read, t3
  end
end