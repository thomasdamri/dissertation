require "rails_helper"
require 'cancan/matchers'

describe "Viewing admin pages" do
  before(:each) do
    mod = create :uni_module, name: "Example Module"
    t = create :team, number: '71', uni_module: mod
    create :user, staff: false, username: "zzz12lo", email: "l@gmail.com"
    create :user, staff: true, username: "zzz12rt", email: "k@gmail.com"

    u1 = create :user, staff: false, username: "zzz12lk", email: "p@gmail.com"
    create :student_team, user: u1, team: t
    wl = create :worklog, uni_module: mod, author: u1, content: "Blah blah blah"
  end

  specify "I can only view the admin pages as an admin" do
    admin = create :user, admin: true, staff: true
    ability = Ability.new(admin)
    login_as admin, scope: :user

    expect(ability).to be_able_to :students, :admin
    expect(ability).to be_able_to :staff, :admin
    expect(ability).to be_able_to :modules, :admin
    expect(ability).to be_able_to :teams, :admin
    expect(ability).to be_able_to :worklogs, :admin

    mod = UniModule.first
    t = Team.first
    wl = Worklog.first

    visit "/admin/dashboard"
    expect(page).to have_content "Admin Dashboard"

    # Can see the module, even though the user is not an associated staff member
    visit "/admin/modules"
    expect(page).to have_content mod.title

    # Can also view the work logs for a module
    visit "/admin/worklogs/#{mod.id}"
    expect(page).to have_content wl.content

    visit "/admin/teams"
    expect(page).to have_content t.number

    visit "/admin/students"
    student = User.where(staff: false).first
    staff = User.where(staff: true).first
    expect(page).to have_content student.username
    expect(page).to_not have_content staff.username

    visit "/admin/staff"
    expect(page).to have_content staff.username
    expect(page).to_not have_content student.username
  end

  specify "I cannot view the admin pages as a non-admin" do
    staff = User.where(staff: true, admin: false).first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    expect(ability).to_not be_able_to :students, :admin
    expect(ability).to_not be_able_to :staff, :admin
    expect(ability).to_not be_able_to :modules, :admin
    expect(ability).to_not be_able_to :teams, :admin
    expect(ability).to_not be_able_to :worklogs, :admin
  end
end

describe "Manually adding users" do
  before(:each) do
    admin = create :user, staff: true, admin: true
  end

  specify "As an admin I can add a new student manually" do
    admin = User.where(admin: true).first
    login_as admin, scope: :user
    ability = Ability.new(admin)

    expect(ability).to be_able_to :add_new_student, :admin
    expect(ability).to be_able_to :new_student_process, :admin

    visit "/admin/students"
    click_link "Add New Student"

    fill_in "CiCS Username", with: ""
    fill_in "Email Address", with: "madeup12@sheffield.ac.uk"
    fill_in "Display Name (optional)", with: "Bob Smith"

    click_button "Create Student"

    expect(page).to_not have_content "Successfully added student"

    fill_in "CiCS Username", with: "zzz12pl"
    fill_in "Email Address", with: ""

    click_button "Create Student"

    expect(page).to_not have_content "Successfully added student"

    fill_in "Email Address", with: "madeup12@sheffield.ac.uk"

    click_button "Create Student"

    # Should see the new user in the students table after submission
    within(:css, '#userTable'){
      expect(page).to have_content "Bob Smith"
    }

    # Login as new user to test permissions
    new_user = User.where(username: "zzz12pl").first
    ability = Ability.new(new_user)

    expect(ability).to_not be_able_to :create, UniModule
    expect(ability).to_not be_able_to :student, :admin
  end

  specify "As an admin I can add a new staff member manually" do
    admin = User.where(admin: true).first
    login_as admin, scope: :user
    ability = Ability.new(admin)

    expect(ability).to be_able_to :add_new_staff, :admin
    expect(ability).to be_able_to :new_staff_process, :admin

    visit "/admin/staff"
    click_link "Add New Staff"

    fill_in "CiCS Username", with: "zzz12pl"
    fill_in "Email Address", with: "madeup12@sheffield.ac.uk"
    fill_in "Display Name (optional)", with: "Bob Smith"

    click_button "Create Staff"

    # Should see the new user in the students table after submission
    within(:css, '#userTable'){
      expect(page).to have_content "Bob Smith"
    }

    # Login as new user to test permissions
    new_user = User.where(username: "zzz12pl").first
    ability = Ability.new(new_user)

    expect(ability).to be_able_to :create, UniModule
    expect(ability).to_not be_able_to :student, :admin
  end

  specify "As an admin I can add a new admin user manually" do
    admin = User.where(admin: true).first
    login_as admin, scope: :user
    ability = Ability.new(admin)

    visit "/admin/staff"
    click_link "Add New Staff"

    fill_in "CiCS Username", with: "zzz12pl"
    fill_in "Email Address", with: "madeup12@sheffield.ac.uk"
    fill_in "Display Name (optional)", with: "Bob Smith"
    check "Admin?"

    click_button "Create Staff"

    # Should see the new user in the students table after submission
    within(:css, '#userTable'){
      expect(page).to have_content "Bob Smith"
    }

    # Login as new user to test permissions
    new_user = User.where(username: "zzz12pl").first
    ability = Ability.new(new_user)

    expect(ability).to be_able_to :create, UniModule
    expect(ability).to be_able_to :student, :admin
  end

  specify "As a non-admin I cannot add a new user" do
    admin = create :user, admin: false, staff: true, username: "zzz12er", email: "something@gmail.com"
    login_as admin, scope: :user
    ability = Ability.new(admin)

    expect(ability).to_not be_able_to :add_new_student, :admin
    expect(ability).to_not be_able_to :add_new_staff, :admin
    expect(ability).to_not be_able_to :new_student_process, :admin
    expect(ability).to_not be_able_to :new_staff_process, :admin

  end
end