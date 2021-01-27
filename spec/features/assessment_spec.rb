require 'rails_helper'
require "cancan/matchers"

describe 'Creating an assessment' do
  specify 'I can create an assessment if I am part of the module', js: true do
    # Create staff user and login
    staff = create(:user, staff: true)
    login_as staff, scope: :user
    # Create module associated with the user
    mod = create :uni_module
    create :staff_module, user: staff, uni_module:  mod
    # Visit page for creating new assessment for the module
    visit "/assessment/new/#{mod.id}"
    fill_in 'Name', with: 'Test Assessment'
    click_link 'Add Question - Text Response'
    fill_in 'Field Title', with: 'Field test'
    choose 'Single Answer'
    click_button 'Create Assessment'
    # Expect to see the assessment page
    expect(page).to have_content "Test Assessment"
    expect(page).to have_content "Team Grades"
  end

  specify 'I cannot create an assessment if I am not part of the module, but still staff' do
    # Create staff user and login
    staff = create(:user, staff: true)
    login_as staff, scope: :user
    # Create module associated with a different user
    other_user = create :user, staff: true, username: 'zzz12ab', email: 'something@gmail.com'
    mod = create :uni_module
    create :staff_module, user: other_user, uni_module:  mod

    expect {
    # Visit page for creating new assessment for the module
    visit "/assessment/new/#{mod.id}"
    }.to raise_error ActionController::RoutingError
  end

  specify 'I cannot create an assessment if I am a student' do
    # Create staff user and login
    student = create(:user, staff: false)
    login_as student, scope: :user
    # Create module associated with a different user
    other_user = create :user, staff: true, username: 'zzz12ab', email: 'something@gmail.com'
    mod = create :uni_module
    create :staff_module, user: other_user, uni_module:  mod

    expect {
      # Visit page for creating new assessment for the module
      visit "/assessment/new/#{mod.id}"
    }.to raise_error ActionController::RoutingError
  end

  specify 'When creating an assessment I can delete some criteria', js: true do
    staff = create :user, staff: true
    login_as staff

    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    visit "/assessment/new/#{mod.id}"

    name = "Deletion test"
    fill_in "Name", with: name

    click_link "Add Question - Whole Number Response"

    input_box = page.all('.crit-input').last
    within(input_box){
      expect(page).to have_content "Whole Number Response Question"
      fill_in "Field Title", with: "Integer Question"
      fill_in "Min value", with: "1"
      fill_in "Max value", with: "10"
      choose "Team Answer"
      choose "Yes"
      fill_in "Relative Weighting", with: "2"
    }

    click_link "Add Question - Decimal Number Response"

    input_box = page.all('.crit-input').last
    within(input_box){
      expect(page).to have_content "Decimal Number Response Question"
      fill_in "Field Title", with: "Decimal Question"
      fill_in "Minimum Value", with: "1.7"
      fill_in "Maximum Value", with: "10.3"
      choose "Team Answer"
      choose "Yes"
      fill_in "Relative Weighting", with: "1"
    }

    click_link "Add Question - Boolean Response"

    input_box = page.all('.crit-input').last
    within(input_box){
      expect(page).to have_content "Boolean Response Question"
      fill_in "Field Title", with: "Boolean Question"
      fill_in "Positive Label", with: "Yes"
      fill_in "Negative Label", with: "No"
      choose "Team Answer"
      click_link "Remove Question"
    }

    click_button "Create Assessment"

    expect(page).to have_content name
    expect(page).to have_content "Total criteria: 2"

  end

  specify 'I can create an assessment with a criterium of every single type', js: true do
    staff = create :user, staff: true
    login_as staff

    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    visit "/assessment/new/#{mod.id}"

    name = "All Data Types Test"
    fill_in "Name", with: name

    click_link "Add Question - Text Response"

    input_box = page.all('.crit-input').last
    within(input_box){
      expect(page).to have_content "Text Response Question"
      fill_in "Field Title", with: "Text Question"
      choose "Single Answer"
    }

    click_link "Add Question - Whole Number Response"

    input_box = page.all('.crit-input').last
    within(input_box){
      expect(page).to have_content "Whole Number Response Question"
      fill_in "Field Title", with: "Integer Question"
      fill_in "Min value", with: "1"
      fill_in "Max value", with: "10"
      choose "Team Answer"
      choose "Yes"
      fill_in "Relative Weighting", with: "2"
    }

    click_link "Add Question - Decimal Number Response"

    input_box = page.all('.crit-input').last
    within(input_box){
      expect(page).to have_content "Decimal Number Response Question"
      fill_in "Field Title", with: "Decimal Question"
      fill_in "Minimum Value", with: "1.7"
      fill_in "Maximum Value", with: "10.3"
      choose "Team Answer"
      choose "Yes"
      fill_in "Relative Weighting", with: "1"
    }

    click_link "Add Question - Boolean Response"

    input_box = page.all('.crit-input').last
    within(input_box){
      expect(page).to have_content "Boolean Response Question"
      fill_in "Field Title", with: "Boolean Question"
      fill_in "Positive Label", with: "Yes"
      fill_in "Negative Label", with: "No"
      choose "Team Answer"
    }

    click_button "Create Assessment"

    expect(page).to have_content name
  end

end

describe 'Removing an assessment' do
  specify 'I can remove an assessment if I am part of the module' do
    # Create staff user and login
    staff = create(:user, staff: true)
    login_as staff, scope: :user
    # Create module associated with the user
    mod = create :uni_module
    create :staff_module, user: staff, uni_module:  mod

    # Create the assessment to delete
    a = create :assessment, uni_module: mod
    create :criterium, assessment: a

    # Visit page of the parent module
    visit "/uni_modules/#{mod.id}"
    # Should be able to see assessment in the table
    expect(page).to have_content a.name
    tr = page.first('tr', text: a.name)
    row = tr.find(:xpath, '..')

    expect(Assessment.count).to eq 1
    within(row){
      click_link "Delete"
    }
    # Assessment count should decrease by 1
    expect(Assessment.count).to eq 0
    within(:css, '#modAssessTable'){
      expect(page).to_not have_content a.name
    }
  end

  specify 'I cannot remove an assessment if I am not part of the module, but still staff' do
    # Create staff user and login
    staff = create(:user, staff: true)
    login_as staff, scope: :user
    # Create module associated with another user
    other = create :user, staff: true, username: 'zzz12ab', email: 'something@gmail.com'
    mod = create :uni_module
    create :staff_module, user: other, uni_module:  mod

    # Create the assessment to delete
    a = create :assessment, uni_module: mod
    create :criterium, assessment: a

    # Non-associated staff can still view the details of other modules so can visit the page
    visit "/uni_modules/#{mod.id}"

    # Should be able to see assessment in the table
    expect(page).to have_content a.name
    tr = page.first('tr', text: a.name)
    row = tr.find(:xpath, '..')

    expect(Assessment.count).to eq 1
    # This should throw an error due to lack of permissions
    expect{
      within(row){
        click_link "Delete"
      }
    }.to raise_error ActionController::RoutingError

    # Assessment count should stay the same
    expect(Assessment.count).to eq 1

    # The page should still have the assessment listed
    visit "/uni_modules/#{mod.id}"
    within(:css, '#modAssessTable'){
      expect(page).to have_content a.name
    }
  end

  specify 'I cannot remove an assessment if I am a student' do
    # Create staff user and login
    student = create(:user, staff: false)
    ability = Ability.new(student)
    login_as student, scope: :user
    # Create module associated with another user
    other = create :user, staff: true, username: 'zzz12ab', email: 'something@gmail.com'
    mod = create :uni_module
    create :staff_module, user: other, uni_module:  mod

    # Create the assessment to delete
    a = create :assessment, uni_module: mod
    create :criterium, assessment: a

    # Student cannot even view the module page to find the delete button
    expect(ability).to_not be_able_to(:read, mod)
    # Student cannot delete the assessment
    expect(ability).to_not be_able_to(:delete, a)
  end
end


describe 'Filling in an assessment' do
  # Setup an assessment to fill in and a team to be in
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    a = create :assessment, uni_module: mod
    create :criterium, assessment: a, title: 'Test 1', response_type: 1, min_value: 1, max_value: 10
    create :criterium, assessment: a, title: 'Test 2', response_type: 1, single: false, min_value: 1, max_value: 10

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

  # This test needs to have js: true, even though it doesn't have any remote component
  specify 'I can fill in an assessment if I am a student who is on the module, but only once, and all fields must be filled', js: true do
    student = User.where(username: 'zzz12ac').first
    login_as student, scope: :user

    t = Team.first
    a = Assessment.first

    c1 = a.criteria.where(single: true).first
    c2 = a.criteria.where(single: false).first

    user_ids = t.users.pluck(:id)

    visit "/teams/#{t.id}"

    # Should be able to see assessment in the table
    expect(page).to have_content a.name
    tr = page.first('tr', text: a.name)
    row = tr.find(:xpath, '..')

    within(row){
      click_link 'Fill In'
    }

    # Clicking submit now will do nothing, as no forms are filled in
    click_button 'Submit'
    expect(page).to_not have_content "Team #{t.id}"

    fill_in "response_#{c1.id}", with: '5'

    # Partially filling in the form does not work either
    click_button "Submit"
    expect(page).to_not have_content "Team #{t.id}"

    user_ids.each do |u_id|
      fill_in "response_#{c2.id}_#{u_id}", with: '7'
    end

    expect(a.completed_by?(student)).to eq false
    click_button 'Submit'

    # I can't find the button that now says 'Filled in' because it's disabled
    expect(page).to have_content "Team #{t.number}"
    expect(a.completed_by?(student)).to eq true

    # Try to fill it in again
    visit "/assessment/#{a.id}/fill_in"
    # Expect to be redirected to the team page
    expect(page).to have_content "Team #{t.number}"

  end

  specify 'I cannot fill in an assessment as a staff member on the module' do
    staff = User.where(staff: true).first
    ability = Ability.new(staff)
    login_as staff, scope: :user

    t = Team.first
    a = Assessment.first

    visit "/teams/#{t.id}"

    # Should be able to see assessment in the table
    expect(page).to have_content a.name
    td = page.first('td', text: a.name)
    row = td.find(:xpath, '..')

    # Cannot see fill in button on this page, not rendered
    within(row){
      expect(page).to_not have_content 'Fill In'
    }

    # Attempt to access the fill in page
    expect(ability).to_not be_able_to(:fill_in, a)
    # Attempt to send the filled in assessment
    expect(ability).to_not be_able_to(:process_assess, a)
  end

  specify 'I cannot fill in an assessment as a student on a different module' do
    # This student is not on this module
    student = create :user, staff: false, username: 'zzz12ab', email: 'something@gmail.com'
    ability = Ability.new(student)
    login_as student, scope: :user

    a = Assessment.first

    # Cannot reach the page for filling in the assessment
    expect(ability).to_not be_able_to(:fill_in, a)
    # Cannot submit a filled in assessment
    expect(ability).to_not be_able_to(:process_assess, a)
  end

  specify 'I can fill in an assessment with criteria of multiple data types' do
    t = Team.first
    mod = UniModule.first

    student = t.users.first
    ability = Ability.new(student)
    login_as student, scope: :user

    a = create :assessment, uni_module: mod, name: "All data types test"
    create :criterium, assessment: a, title: 'Test 1', response_type: 0
    create :criterium, assessment: a, title: 'Test 2', response_type: 1, min_value: 1, max_value: 10
    create :criterium, assessment: a, title: 'Test 3', response_type: 2, min_value: 1.1, max_value: 10.1
    create :criterium, assessment: a, title: 'Test 4', response_type: 3, min_value: "No", max_value: "Yes"

    visit "/teams/#{t.id}"

    # Find the row in the assessment table for this assessment
    row = nil
    within(:css, '#studentAssessTable'){
      td = page.first('td', text: a.name)
      row = td.find(:xpath, '..')
    }

    within(row){
      click_link "Fill In"
    }

    a.criteria.each do |crit|
      div = page.first('div.crit-fillin', text: crit.title)
      within(div){
        if crit.response_type == Criterium.string_type
          fill_in "response_#{crit.id}", with: "String response"
        elsif crit.response_type == Criterium.int_type
          fill_in "response_#{crit.id}", with: "1"
        elsif crit.response_type == Criterium.float_type
          fill_in "response_#{crit.id}", with: "4.5"
        elsif crit.response_type == Criterium.bool_type
          choose "No"
        end
      }
    end
    click_button "Submit"

    # Find the row in the assessment table for this assessment
    row = nil
    within(:css, '#studentAssessTable'){
      td = page.first('td', text: a.name)
      row = td.find(:xpath, '..')
    }

    within(row){
      # Button should be blanked out - assessment filled in
      expect(page).to_not have_content "Fill In"
    }

  end

end

describe "Viewing the assessment page" do
  specify "Only associated staff should be able to view the assessment page" do
    staff = create :user, staff: true
    other_staff = create :user, staff: true, username: "zzz12lp", email: "l@gmail.com"
    student = create :user, staff: false, username: "zzz12ty", email: "t@gmail.com"

    mod = create :uni_module
    t1 = create :team, uni_module: mod
    create :staff_module, user: staff, uni_module: mod
    create :student_team, team: t1, user: student

    a = create :assessment, uni_module: mod

    ability = Ability.new(staff)
    expect(ability).to be_able_to :read, a
    ability = Ability.new(other_staff)
    expect(ability).to_not be_able_to :read, a
    ability = Ability.new(student)
    expect(ability).to_not be_able_to :read, a

  end
end

describe 'Viewing and modifying assessment results' do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    # Make assessment close tomorrow to prevent looking at results early
    a = create :assessment, uni_module: mod, date_closed: Date.today + 1

    c = create :weighted_criterium, assessment: a
    c2 = create :criterium, assessment: a, title: 'Something else'

    u1 = create :user, staff: false, username: 'zzz12ac', email: 'something@gmail.com'
    u2 = create :user, staff: false, username: 'zzz12ad', email: 'something2@gmail.com'
    u3 = create :user, staff: false, username: 'zzz12ae', email: 'something3@gmail.com'
    u4 = create :user, staff: false, username: 'zzz12af', email: 'something4@gmail.com'

    t = create :team, uni_module: mod

    create :team_grade, team: t, assessment: a, grade: 70

    create :student_team, user: u1, team: t
    create :student_team, user: u2, team: t
    create :student_team, user: u3, team: t
    create :student_team, user: u4, team: t

    create :assessment_result, author: u1, target: u1, criterium: c, value: '7'
    create :assessment_result, author: u1, target: u2, criterium: c, value: '8'
    create :assessment_result, author: u1, target: u3, criterium: c, value: '9'
    create :assessment_result, author: u1, target: u4, criterium: c, value: '7'

    create :assessment_result, author: u1, target: nil, criterium: c2, value: 'Some text'

    a.generate_weightings(t)
  end

  specify 'I can view my assessment results as a student only once the closing date has passed', js: true do
    student = User.where(username: 'zzz12ac').first
    login_as student, scope: :user

    t = Team.first
    a = Assessment.first

    visit "/teams/#{t.id}"

    within(:css, '#studentAssessTable'){
      expect(page).to have_content a.name
    }

    tr = page.first('tr', text: a.name)
    row = tr.find(:xpath, '..')

    within(row){
      # The results button should be disabled, so RSpec can't see it
      expect(row).to_not have_content "Results"
    }

    # Alter date so that assessment is finished
    a.date_closed = Date.today - 1
    a.save

    # Refresh the page
    visit "/teams/#{t.id}"

    within(:css, '#studentAssessTable'){
      expect(page).to have_content a.name
    }

    tr = page.first('tr', text: a.name)
    row = tr.find(:xpath, '..')

    within(row){
      click_button "Results"
    }

    tg = TeamGrade.where(team: t, assessment: a).first
    sw = StudentWeighting.where(user: student, assessment: a).first
    final_grade = tg.grade.to_f * sw.weighting.to_f

    within(:css, '#resultsModal'){
      expect(page).to have_content "Team grade: #{tg.grade}"
      expect(page).to have_content "Your weighting: #{sw.weighting.round(2)}"
      expect(page).to have_content "Your grade: #{final_grade.round(2)}"
    }

  end

  specify "As staff I can see all student's individual grades", js: true  do
    staff = User.where(staff: true).first
    login_as staff, scope: :user

    t = Team.first
    a = Assessment.first

    visit "/assessment/#{a.id}"

    # Find the row in the table with the team's number in it
    row = nil
    within(:css, '#gradeTable'){
      row = page.first('td', text: t.number).find(:xpath, '..')
    }
    within(row){
      click_link 'View Individual Grades'
    }

    # Find each user's grade in the modal table
    table = page.find(:css, '#indGradeTable')
    t.users.each do |u|
      sw = StudentWeighting.where(user: u, assessment: a).first
      within(table){
        expect(page).to have_content sw.weighting
      }
    end

  end

  specify 'As staff I can see individual student responses to the assessment', js: true do
    staff = User.where(staff: true).first
    login_as staff, scope: :user

    t = Team.first
    a = Assessment.first

    visit "/teams/#{t.id}"

    row = nil
    within(:css, '#staffAssessTable'){
      row = page.first('td', text: a.name).find(:xpath, '..')
    }
    within(row){
      click_link 'View Individual Responses'
    }

    a.criteria.each do |crit|
      within(:css, "#indResponseTable_#{crit.id}"){
        # If criteria is single, just do one search, as there is only one response
        if crit.single
          ar = AssessmentResult.where(criterium: crit).first
          expect(page).to have_content ar.value
        else
          # If criteria is not single, search for the response targeting each user
          t.users.each do |u|
            ar = AssessmentResult.where(target: u, criterium: crit).first
            expect(page).to have_content ar.value
          end
        end
      }
    end

  end

  specify 'As a student I cannot see the individual student responses to the assessment, even when on the same team' do
    student = User.where(staff: false).first
    ability = Ability.new(student)
    login_as student, scope: :user

    t = Team.first
    a = Assessment.first

    visit "/teams/#{t.id}"

    # Students should not see the table with staff options
    expect(page).to have_selector '#studentAssessTable'
    expect(page).to_not have_selector '#staffAssessTable'
    expect(page).to_not have_content "View Individual Responses"

    # Students should not be able to see individual responses
    expect(ability).to_not be_able_to(:get_ind_responses, a)

  end

  specify "As staff I can change a student's individual weight manually, then change it back", js: true do
    staff = User.where(staff: true).first
    login_as staff, scope: :user

    t = Team.first
    a = Assessment.first

    # Give student a recognisable name so they can be found in the table
    student = t.users.first
    student.display_name = "Dan Perry"
    student.save

    visit "/assessment/#{a.id}"

    # Find the button for this team to bring up individual grades
    row = nil
    within(:css, '#gradeTable'){
      row = page.first('td', text: t.number).find(:xpath, '..')
    }
    within(row){
      click_link 'View Individual Grades'
    }

    # Find the first student in the team, and the row with their grade in
    #row = nil
    within(:css, "#indGradeTable"){
      row = page.first('td', text: student.real_display_name).find(:xpath, '..')
    }

    current_weight = StudentWeighting.where(assessment: a, user: student).first
    old_weighting = current_weight.weighting

    new_val = 0.7

    # Get the weighting to identify the input field
    within(row){
      # Should see current weighting there
      expect(page).to have_content old_weighting
      # Should see "No" in the "Manually set" column
      expect(page).to have_content "No"
      # Update weighting
      fill_in "new_weight_#{current_weight.id}", with: new_val

    }
    click_button "Update Grades"

    # Page has now reloaded, re-open the modal
    row = nil
    within(:css, '#gradeTable'){
      row = page.first('td', text: t.number).find(:xpath, '..')
    }
    within(row){
      click_link 'View Individual Grades'
    }

    # Find the row for the current user
    within(:css, '#indGradeTable'){
      row = page.first('td', text: student.real_display_name).find(:xpath, '..')
    }

    within(row){
      # Should only see the manually set grading, not the generated one
      expect(page).to have_content new_val
      expect(page).to_not have_content old_weighting
      # Should also see "Yes" for the manually set column
      expect(page).to have_content "Yes"

      # Click the reset button
      check "reset_check_#{current_weight.id}"
    }
    # Click update to submit changes
    click_button "Update Grades"

    # Re-find the team's row again and re-open the modal
    within(:css, '#gradeTable'){
      row = page.first('td', text: t.number).find(:xpath, '..')
    }
    within(row){
      click_link 'View Individual Grades'
    }

    # Find the row for the current user
    within(:css, '#indGradeTable'){
      row = page.first('td', text: student.real_display_name).find(:xpath, '..')
    }

    within(row){
      # Should only see the auto-generated one, not the manual one
      expect(page).to_not have_content new_val
      expect(page).to have_content old_weighting
      # Should also see "No" for the manually set column
      expect(page).to have_content "No"
    }

  end

  specify "As a student I cannot see other students' weightings or change them" do
    t = Team.first
    a = Assessment.first

    student = t.users.first
    ability = Ability.new(student)
    login_as student, scope: :user

    expect(ability).to be_able_to(:read, t)
    expect(ability).to_not be_able_to(:view_ind_grades, t)
    expect(ability).to_not be_able_to(:update_ind_grades, t)
  end
end

describe "Downloading results" do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    a = create :assessment, uni_module: mod

    c = create :weighted_criterium, assessment: a

    u1 = create :user, staff: false, username: 'zzz12ac', email: 'something@gmail.com'
    u2 = create :user, staff: false, username: 'zzz12ad', email: 'something2@gmail.com'
    u3 = create :user, staff: false, username: 'zzz12ae', email: 'something3@gmail.com'
    u4 = create :user, staff: false, username: 'zzz12af', email: 'something4@gmail.com'

    t = create :team, uni_module: mod

    create :student_team, user: u1, team: t
    create :student_team, user: u2, team: t
    create :student_team, user: u3, team: t
    create :student_team, user: u4, team: t

    create :assessment_result, author: u1, target: u1, criterium: c, value: '7'
    create :assessment_result, author: u1, target: u1, criterium: c, value: '8'
    create :assessment_result, author: u1, target: u1, criterium: c, value: '9'
    create :assessment_result, author: u1, target: u1, criterium: c, value: '7'

    a.generate_weightings(t)

  end

  specify "As staff I can download all the results for an assessment" do
    staff = User.where(staff: true).first
    login_as staff, scope: :user

    mod = UniModule.first
    a = Assessment.first

    visit "/uni_modules/#{mod.id}"

    within(:css, '#modAssessTable'){
      expect(page).to have_content a.name
      click_link 'Download all grades'
    }

    expect(page.text).to have_content "Student Username,Team Number,Team Grade,Individual Weighting,Individual Grade"
  end

  specify "As a student I cannot download all the results for an assessment" do
    student = User.where(staff: false).first
    login_as student, scope: :user

    # Need to visit at least one page before the routing errors can take effect for some reason
    visit '/'

    t = student.teams.first

    mod = UniModule.first
    a = Assessment.first

    # Cannot view the module page
    expect{
      visit "/uni_modules/#{mod.id}"
    }.to raise_error ActionController::RoutingError

    expect {
      visit "/assessment/#{a.id}/export.csv"
    }.to raise_error ActionController::RoutingError

  end
end

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
