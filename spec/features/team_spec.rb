require "rails_helper"
require "cancan/matchers"

describe 'Uploading teams' do

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
    ability.should be_able_to :read, t
    visit "/teams/#{t.id}"
    # Staff can see the staff assessment table (cannot see option to fill in assessment)
    expect(page).to_not have_selector '#studentAssessTable'
    expect(page).to have_selector '#staffAssessTable'

    # Staff cannot access the team page for other modules
    login_as other_staff, scope: :user
    ability = Ability.new(other_staff)
    ability.should_not be_able_to :read, t

    # Students can access their own team page
    student = t.users.first
    login_as student, scope: :user
    ability = Ability.new(student)
    ability.should be_able_to :read, t
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
    ability.should_not be_able_to :read, t2

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
    ability.should_not be_able_to :read, t3
  end
end