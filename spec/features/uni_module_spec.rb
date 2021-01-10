require "rails_helper"
require "cancan/matchers"

describe "Creating a module" do

  specify "I can create a module if I am a staff member, and add other staff members to the module", js: true do
    staff = create :user, staff: true, display_name: "Person 1"
    other_staff1 = create :user, staff: true, username: "zzz12pl", email: "a@gmail.com", display_name: "Person 2"
    other_staff2 = create :user, staff: true, username: "zzz12pd", email: "b@gmail.com", display_name: "Person 3"

    login_as staff, scope: :user
    ability = Ability.new(staff)

    expect(ability).to be_able_to :new, UniModule
    expect(ability).to be_able_to :create, UniModule

    visit "/uni_modules/new"
    fill_in "Module Code", with: "TST1001"
    fill_in "Module Name", with: "Test Module"

    click_link "Add Staff Member"

    staff_fields = page.all('.staff-fields').last
    within(staff_fields){
      select other_staff1.email
    }

    click_link "Add Staff Member"
    staff_fields = page.all('.staff-fields').last
    within(staff_fields){
      select other_staff2.email
      click_link "Remove Staff Member"
    }

    click_button "Create Module"

    within(:css, '#modInfo'){
      expect(page).to have_content staff.real_display_name
      expect(page).to have_content other_staff1.real_display_name
      expect(page).to_not have_content other_staff2.real_display_name
    }

  end

  specify "I cannot create a module if I am a student" do
    student = create :user, staff: false
    ability = Ability.new(student)
    expect(ability).to_not be_able_to :create, UniModule
    expect(ability).to_not be_able_to :new, UniModule
  end

end


describe "Editing a module" do
  specify "I can change a module's name and code as a staff member associated with the module" do
    staff = create :user, staff: true
    ability = Ability.new(staff)
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    old_title = mod.title

    expect(ability).to be_able_to :edit, mod
    expect(ability).to be_able_to :update, mod

    login_as staff, scope: :user
    visit "/home/staff_home"
    row = page.find('tr', text: old_title)
    within(row){
      click_link "Edit"
    }

    new_name = "New name"
    new_code = "NEW1001"
    fill_in "Module Name", with: new_name
    fill_in "Module Code", with: new_code
    click_button "Update Module"

    expect(page).to have_content "#{new_code} #{new_name}"
    expect(page).to_not have_content old_title

  end

  specify "I can add and remove additional staff members to the module as a staff member already associated with it", js: true do
    staff = create :user, staff: true, display_name: "Name 1"
    other_staff1 = create :user, staff: true, username: "zzz12rt", email: "e@gmail.com", display_name: "Name 2"
    other_staff2 = create :user, staff: true, username: "zzz12rf", email: "f@gmail.com", display_name: "Name 3"
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    login_as staff, scope: :user
    visit "/home/staff_home"
    row = page.find("tr", text: mod.title)

    within(row){
      click_link "Edit"
    }

    # Remove the additional staff member
    staff_fields = page.all('.staff-fields').last
    within(staff_fields){
      click_link "Remove Staff Member"
    }

    # Add another staff member
    click_link "Add Staff Member"

    staff_fields = page.all('.staff-fields').last
    within(staff_fields){
      select other_staff2.email
    }

    click_button "Update Module"

    within(:css, '#modInfo'){
      expect(page).to have_content other_staff2.real_display_name
      expect(page).to_not have_content other_staff1.real_display_name
    }

    # Check the permission for otherstaff1 has been removed
    ability = Ability.new(other_staff1)
    expect(ability).to_not be_able_to :update, mod
    # Check the permission for otherstaff2 has been added
    ability = Ability.new(other_staff2)
    expect(ability).to be_able_to :update, mod

  end

  specify 'I cannot remove every staff member from an existing module', js: true do
    staff = create :user, staff: true
    other_staff1 = create :user, staff: true, username: "zzz12er", email: "e@gmail.com"
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    create :staff_module, user: other_staff1, uni_module: mod

    login_as staff, scope: :user

    visit "/uni_modules/#{mod.id}/edit"

    # Remove both staff members
    staff_fields = page.all('.staff-fields').last
    within(staff_fields){
      click_link "Remove Staff Member"
    }

    # Remove the additional staff member
    staff_fields = page.all('.staff-fields').last
    within(staff_fields){
      click_link "Remove Staff Member"
    }

    click_button "Update Module"

    # Expect to stay on the update page, and not be redirected
    expect(page).to have_content "Editing Module: #{mod.name}"

  end

  specify "I cannot change the module if I am not associated with it" do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    other_staff = create :user, staff: true, username: "zzz12as", email: "p@gmail.com"
    ability = Ability.new(other_staff)

    expect(ability).to_not be_able_to :edit, mod
    expect(ability).to_not be_able_to :update, mod
  end

  specify "I cannot change the module if I am a student" do
    staff = create :user, staff: true
    student = create :user, staff: false, username: "zzz12dv", email: "l@gmail.com"
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    ability = Ability.new(student)
    expect(ability).to_not be_able_to :edit, mod
    expect(ability).to_not be_able_to :update, mod
  end
end


describe "Deleting a module" do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
  end

  specify "I can delete a module as an associated staff member", js: true do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    mod = UniModule.first

    expect(ability).to be_able_to :delete, mod

    visit "/home/staff_home"
    row = page.find('tr', text: mod.title)
    within(row){
      click_link "Delete"
    }
    page.accept_alert "Are you sure? This is a permanent action that will remove all module data?"

    expect(page).to_not have_content mod.title
  end

  specify "I cannot delete a module as an unassociated staff member" do
    other_staff = create :user, staff: true, username: "zzz12th", email: "a@gmail.com"
    login_as other_staff, scope: :user
    ability = Ability.new(other_staff)

    mod = UniModule.first

    expect(ability).to_not be_able_to :delete, mod

    # Cannot see the module in the list of modules on the staff dashboard
    visit "/home/staff_home"
    expect(page).to_not have_content mod.title

  end

  specify "I cannot delete a module as a student" do
    student = create :user, staff: false, username: "zzz12lk", email: "a@gmail.com"
    login_as student, scope: :user
    ability = Ability.new(student)

    mod = UniModule.first

    expect(ability).to_not be_able_to :delete, mod

    # Should be redirected to the student homepage
    visit "/home/staff_home"
    # Dashboard links mean I have to manually search for the h1 titles
    expect{
      page.find('h1', text: "Staff Dashboard")
    }.to raise_exception Capybara::ElementNotFound

    page.find('h1', text: "Student Dashboard")
  end
end

describe "Uploading users" do
  specify "I can upload student data from a CEIS TSV file and have it put in the system as a staff member", js: true do
    staff = create :user, staff: true
    login_as staff, scope: :user
    ability = Ability.new(staff)

    expect(ability).to be_able_to :upload_users, UniModule
    expect(ability).to be_able_to :user_process, UniModule

    old_user_num = User.all.count

    visit "/home/staff_home"
    click_link "Add Students"
    attach_file "spec/uploads/users.tsv"
    click_button "Import"

    # There were 6 more users in the file, number of users should have increased by 6
    expect(User.all.count).to eq old_user_num + 6
  end

  specify "If no file is selected, the user is prompted to select one", js: true do
    staff = create :user, staff: true
    login_as staff, scope: :user

    visit "/home/staff_home"
    click_link "Add Students"

    click_button "Import"

    expect(page).to have_content "Upload failed. Please attach a file before attempting upload"
  end

  specify "If I am a student I cannot upload student data" do
    student = create :user, staff: false
    ability = Ability.new(student)
    expect(ability).to_not be_able_to :upload_users, UniModule
    expect(ability).to_not be_able_to :user_process, UniModule
  end

  specify "If a user is already in the system, they are not added again", js: true do
    staff = create :user, staff: true
    # Create a student from the users.tsv file
    create :user, staff: false, username: "zzx12tu", email: "tuser1@sheffield.ac.uk"

    login_as staff, scope: :user

    visit "/home/staff_home"
    click_link "Add Students"
    attach_file "spec/uploads/users.tsv"
    click_button "Import"

    # Should have added 1 less than there were in the file
    expect(page).to have_content "Successfully added 5 students"
  end
end

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