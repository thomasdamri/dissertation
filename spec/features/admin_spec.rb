require "rails_helper"

describe "Viewing admin pages" do
  before(:each) do
    mod = create :uni_module, name: "Example Module"
    t = create :team, number: '71', uni_module: mod
    create :user, staff: false, username: "zzz12lo", email: "l@gmail.com"
    create :user, staff: true, username: "zzz12rt", email: "k@gmail.com"
  end

  specify "I can only view the admin pages as an admin" do
    admin = create :user, admin: true, staff: true
    login_as admin, scope: :user

    mod = UniModule.first
    t = Team.first

    # Can see the module, even though the user is not an associated staff member
    visit "/admin/modules"
    expect(page).to have_content mod.title

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

    expect{
      visit "/admin/modules"
    }.to raise_error ActionController::RoutingError
  end
end