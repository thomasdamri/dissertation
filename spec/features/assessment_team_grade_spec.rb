require "rails_helper"
require "cancan/matchers"

describe "Uploading team grades" do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    create :assessment, uni_module: mod

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
  end

  specify "As a staff member on a module I can upload a CSV of team grades", js: true do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)
    assess = Assessment.first

    expect(ability).to be_able_to :upload_grades, assess
    expect(ability).to be_able_to :process_grades, assess

    visit "/assessment/#{assess.id}"

    # Cannot send grade emails prior to team grade upload
    expect(page).to_not have_content 'Send grades via email'

    click_link "Upload Team Grades"
    attach_file "spec/uploads/grades.csv"
    click_button "Import"

    # Should see the uploaded grades
    within(:css, '#gradeTable'){
      expect(page).to have_content 70
      expect(page).to have_content 57
    }

  end

  specify "If a file is not selected in the team grade form, the user is informed to upload one", js: true do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    assess = Assessment.first

    visit "/assessment/#{assess.id}"
    click_link "Upload Team Grades"
    click_button "Import"

    expect(page).to have_content "Upload failed. Please attach a file before attempting upload"
  end

  specify "As a staff member not associated with a module I cannot upload team grades" do
    other_staff = create :user, username: "zzz12az", email: "z@gmail.com"
    ability = Ability.new(other_staff)
    assess = Assessment.first

    expect(ability).to_not be_able_to :upload_grades, assess
    expect(ability).to_not be_able_to :process_grades, assess
  end

  specify "As a student I cannot upload team grades" do
    student = User.where(staff: false).first
    ability = Ability.new(student)
    assess = Assessment.first

    expect(ability).to_not be_able_to :upload_grades, assess
    expect(ability).to_not be_able_to :process_grades, assess
  end

end

describe "Removing team grades" do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    a = create :assessment, uni_module: mod

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

    create :team_grade, team: t1, assessment: a, grade: 56
    create :team_grade, team: t2, assessment: a, grade: 76
  end

  specify "As a staff member on a module I can remove all team grades" do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)
    assess = Assessment.first

    expect(ability).to be_able_to :delete_grades, assess

    visit "/assessment/#{assess.id}"
    click_button "Delete Existing Team Grades"

    expect(page).to have_content "No grade assigned yet"
  end

  specify "As a staff member not associated with a module, I cannot remove team grades" do
    assess = Assessment.first
    other_staff = create :user, staff: true, username: "zzz12xc", email: "p@gmail.com"
    ability = Ability.new(other_staff)
    expect(ability).to_not be_able_to :delete_grades, assess
  end

  specify "As a student I cannot remove team grades" do
    assess = Assessment.first
    student = User.where(staff: false).first
    ability = Ability.new(student)
    expect(ability).to_not be_able_to :delete_grades, assess
  end

end


describe "Altering team grades" do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    create :assessment, uni_module: mod
  end

  specify "I can manually set a team's grade as a member of staff on that module", js: true do
    staff = User.where(staff: true).first
    assess = Assessment.first
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

    ability = Ability.new(staff)
    login_as staff, scope: :user
    expect(ability).to be_able_to :grade_form, assess
    expect(ability).to be_able_to :set_grade, assess

    visit "/assessment/#{assess.id}"

    # Find the row for team 1 (team grade of 56)
    row = page.find('tr', text: "No grade assigned yet", match: :first)
    within(row){
      click_link "Set Grade"
    }

    fill_in "New Grade", with: "34"
    within(:css, '.modal-body'){
      click_button "Set Grade"
    }

    # New grade is in the table, old text is not
    row = page.find('tr', text: "34")
    within(row){
      expect(page).to have_content "34"
      expect(page).to_not have_content  "No grade assigned yet"
    }
  end

  specify "I can manually replace a team's grade as a member of staff on that module", js: true do
    staff = User.where(staff: true).first
    assess = Assessment.first
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

    create :team_grade, team: t1, assessment: assess, grade: 56
    create :team_grade, team: t2, assessment: assess, grade: 76

    ability = Ability.new(staff)
    login_as staff, scope: :user
    expect(ability).to be_able_to :grade_form, assess
    expect(ability).to be_able_to :set_grade, assess

    visit "/assessment/#{assess.id}"

    # Find the row for team 1 (team grade of 56)
    row = page.find('tr', text: "56")
    within(row){
      click_link "Set Grade"
    }

    fill_in "New Grade", with: "34"
    within(:css, '.modal-body'){
      click_button "Set Grade"
    }

    # New grade is in the table, old grade is not
    within(:css, '#gradeTable'){
      expect(page).to have_content "34"
      expect(page).to_not have_content "56"
    }

  end

  specify "I cannot manually change a team's grade if I am a member of staff not associated with the module" do
    other_staff = create :user, staff: true, username: "zzz12pl", email: "i@gmail.com"
    ability = Ability.new(other_staff)
    assess = Assessment.first

    expect(ability).to_not be_able_to :grade_form, assess
    expect(ability).to_not be_able_to :set_grade, assess
  end

  specify "I cannot manually change a team's grade as a student" do
    student = create :user, staff: false, username: "zzz12pl", email: "i@gmail.com"
    ability = Ability.new(student)
    assess = Assessment.first

    expect(ability).to_not be_able_to :grade_form, assess
    expect(ability).to_not be_able_to :set_grade, assess
  end
end
