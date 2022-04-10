require "rails_helper"
require "cancan/matchers"

describe "Changing individual student's weightings " do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    # Make assessment close tomorrow to prevent looking at results early
    a = create :assessment, uni_module: mod, date_closed: Date.today + 1

    c = create :weighted_criteria, assessment: a
    c2 = create :criteria, assessment: a, title: 'Something else'

    u1 = create :user, staff: false, username: 'zzz12ac', email: 'something@gmail.com', display_name: "A Smith"
    u2 = create :user, staff: false, username: 'zzz12ad', email: 'something2@gmail.com', display_name: "B Smith"
    u3 = create :user, staff: false, username: 'zzz12ae', email: 'something3@gmail.com', display_name: "C Smith"
    u4 = create :user, staff: false, username: 'zzz12af', email: 'something4@gmail.com', display_name: "D Smith"

    t = create :team, uni_module: mod

    create :team_grade, team: t, assessment: a, grade: 70

    create :student_team, user: u1, team: t
    create :student_team, user: u2, team: t
    create :student_team, user: u3, team: t
    create :student_team, user: u4, team: t

    create :assessment_result_empty, author: u1, target: u1, criteria: c, value: '7'
    create :assessment_result_empty, author: u1, target: u2, criteria: c, value: '8'
    create :assessment_result_empty, author: u1, target: u3, criteria: c, value: '9'
    create :assessment_result_empty, author: u1, target: u4, criteria: c, value: '7'

    create :assessment_result_empty, author: u1, target: nil, criteria: c2, value: 'Some text'

    a.generate_weightings(t)
  end

  specify "As staff on a module I can change a student's individual weight manually, then change it back", js: true do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    t = Team.first
    a = Assessment.first

    # Give student a recognisable name so they can be found in the table
    student = t.users.first
    student.display_name = "Dan Perry"
    student.save

    sw = StudentWeighting.where(assessment: a, user: student).first

    # Can view page with all individual grades on
    expect(ability).to be_able_to(:view_ind_grades, a)
    # Can update the grades
    expect(ability).to be_able_to(:update_grade_form, sw)
    expect(ability).to be_able_to(:process_grade_update, sw)
    expect(ability).to be_able_to(:reset_grade, sw)

    visit "/assessment/#{a.id}"
    click_link 'View Individual Grades'

    # Find the first student in the team, and the row with their grade in
    row = nil
    within(:css, "#indGradeTable"){
      row = page.first('td', text: student.real_display_name).find(:xpath, '..')
    }

    current_weight = StudentWeighting.where(assessment: a, user: student).first
    old_weighting = current_weight.weighting

    within(row){
      # Should see current weighting there
      expect(page).to have_content old_weighting
      # Should see "No" in the "Manually set" column
      expect(page).to have_content "No"
      click_link "Set Weighting"
    }

    new_val = 0.7
    reason = "Some reason for updating the weighting"

    # Get the weighting to identify the input field
    within(:css, '.modal-body'){
      # Update weighting
      fill_in "new_weight", with: new_val
      fill_in "reason", with: reason
      click_button "Update Weighting"
    }

    # Page has now reloaded, re-find the row
    row = nil

    # Find the row for the current user
    within(:css, '#indGradeTable'){
      row = page.first('td', text: student.real_display_name).find(:xpath, '..')
    }

    within(row){
      # Should only see the manually set grading, not the generated one
      expect(page).to have_content new_val
      expect(page).to_not have_content old_weighting
      # Should also see "Yes" for the manually set column and the reason we gave
      expect(page).to have_content "Yes"
      expect(page).to have_content reason

      # Reset the weighting
      click_button "Reset Weighting"
    }

    # Find the row for the current user as the page has reloaded
    within(:css, '#indGradeTable'){
      row = page.first('td', text: student.real_display_name).find(:xpath, '..')
    }

    within(row){
      # Should only see the auto-generated weighting, not the manual one
      expect(page).to_not have_content new_val
      expect(page).to have_content old_weighting
      # Should also see "No" for the manually set column
      expect(page).to have_content "No"
      # Should not see the reason
      expect(page).to_not have_content reason
    }
  end

  specify "The change individual grade can deal with invalid input", js: true do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    t = Team.first
    a = Assessment.first

    # Give student a recognisable name so they can be found in the table
    student = t.users.first
    student.display_name = "Dan Perry"
    student.save

    sw = StudentWeighting.where(assessment: a, user: student).first

    visit "/assessment/#{a.id}"
    click_link 'View Individual Grades'

    # Find the first student in the team, and the row with their grade in
    row = nil
    within(:css, "#indGradeTable"){
      row = page.first('td', text: student.real_display_name).find(:xpath, '..')
    }

    current_weight = StudentWeighting.where(assessment: a, user: student).first
    old_weighting = current_weight.weighting

    new_val = -0.1
    reason = "Some reason for updating the weighting"

    within(row){
      click_link "Set Weighting"
    }

    # Try inputting invalid data
    within(:css, '.modal-body'){
      # Update weighting
      fill_in "new_weight", with: new_val
      fill_in "reason", with: reason
      click_button "Update Weighting"
    }

    expect(page).to_not have_content "Weighting updated successfully"

    new_val = 0

    within(:css, '.modal-body'){
      # Update weighting
      fill_in "new_weight", with: ""
      fill_in "new_weight", with: new_val
      fill_in "reason", with: ""
      click_button "Update Weighting"
    }

    expect(page).to_not have_content "Weighting updated successfully"

    within(:css, '.modal-body'){
      fill_in "reason", with: "a"
      click_button "Update Weighting"
    }

    expect(page).to have_content "Weighting updated successfully"
  end


  specify "As a student I cannot see other students' weightings or change them" do
    t = Team.first
    a = Assessment.first

    student = t.users.first
    ability = Ability.new(student)
    login_as student, scope: :user

    sw = StudentWeighting.where(assessment: a, user: student).first

    # Cannot view team
    expect(ability).to be_able_to(:read, t)
    # Cannot view page with all individual grades on
    expect(ability).to_not be_able_to(:view_ind_grades, a)
    # Cannot update the grades
    expect(ability).to_not be_able_to(:update_grade_form, sw)
    expect(ability).to_not be_able_to(:process_grade_update, sw)
    expect(ability).to_not be_able_to(:reset_grade, sw)
  end
end