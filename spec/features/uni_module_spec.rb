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

    select Date.today.strftime("%Y"), from: "uni_module_start_date_1i"
    select Date.today.strftime("%B"), from: "uni_module_start_date_2i"
    select Date.today.strftime("%-d"), from: "uni_module_start_date_3i"
    new_date = Date.today + 90
    select new_date.strftime("%Y"), from: "uni_module_end_date_1i"
    select new_date.strftime("%B"), from: "uni_module_end_date_2i"
    select new_date.strftime("%-d"), from: "uni_module_end_date_3i"

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

describe "Viewing all students on a module" do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    s1 = create :user, staff: false, username: "zzz12qw", email: "q@gmail.com", display_name: "Student 1"
    s2 = create :user, staff: false, username: "zzz12qe", email: "e@gmail.com", display_name: "Student 2"
    s3 = create :user, staff: false, username: "zzz12er", email: "r@gmail.com", display_name: "Can't see this"

    t1 = create :team, uni_module: mod
    t2 = create :team, uni_module: mod, number: 2

    create :student_team, team: t1, user: s1
    create :student_team, team: t2, user: s2
  end

  specify "As a member of staff on a module I can view all the students enrolled on the module", js: true do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)
    mod = UniModule.first

    expect(ability).to be_able_to :show_all_students, mod

    visit "/uni_modules/#{mod.id}"
    click_link "Show All Students"

    s1 = User.where(username: "zzz12qw").first
    s2 = User.where(username: "zzz12qe").first
    s3 = User.where(username: "zzz12er").first

    within(:css, '#allStudentTable'){
      expect(page).to have_content s1.real_display_name
      expect(page).to have_content s2.real_display_name
      expect(page).to_not have_content s3.real_display_name
    }
  end

  specify "As a member of staff not associated with a module, I cannot view all the students on it" do
    other_staff = create :user, staff: true, username: "zzz12ty", email: "t@gmail.com"
    ability = Ability.new(other_staff)
    mod = UniModule.first
    expect(ability).to_not be_able_to :show_all_students, mod
  end

  specify "As a student I cannot view all the students on a module" do
    student = create :user, staff: false, username: "zzz12ty", email: "t@gmail.com"
    ability = Ability.new(student)
    mod = UniModule.first
    expect(ability).to_not be_able_to :show_all_students, mod
  end
end