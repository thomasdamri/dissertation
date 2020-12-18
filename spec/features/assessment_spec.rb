require 'rails_helper'

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
    login_as student, scope: :user
    # Create module associated with another user
    other = create :user, staff: true, username: 'zzz12ab', email: 'something@gmail.com'
    mod = create :uni_module
    create :staff_module, user: other, uni_module:  mod

    # Create the assessment to delete
    a = create :assessment, uni_module: mod
    create :criterium, assessment: a

    expect(Assessment.count).to eq 1
    # Expect trying to view the module page will give an error
    expect{
      visit "/uni_modules/#{mod.id}"
    }.to raise_error ActionController::RoutingError
    # Expect the assessment not to have been deleted

    # Try to send a delete request
    page.driver.submit :delete, "/uni_modules/#{mod.id}", {}

    # The assessment should still exist
    expect(Assessment.count).to eq 1
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
    login_as staff, scope: :user

    t = Team.first
    a = Assessment.first

    visit "/teams/#{t.id}"

    # Should be able to see assessment in the table
    expect(page).to have_content a.name
    tr = page.first('tr', text: a.name)
    row = tr.find(:xpath, '..')

    # Cannot see fill in button on this page, not rendered
    within(row){
      expect(page).to_not have_content 'Fill In'
    }

    # Attempt to navigate to the page manually
    expect{
      visit "/assessments/#{a.id}/fill_in"
    }.to raise_error ActionController::RoutingError

    # Sending a manual post request to the form submission url fails
    expect{
      page.driver.submit :post, "/assessments/#{a.id}/process", {}
    }.to raise_error ActionController::RoutingError

  end

  specify 'I cannot fill in an assessment as a student on a different module' do
    # This student is not on this module
    student = create :user, staff: false, username: 'zzz12ab', email: 'something@gmail.com'

    a = Assessment.first

    # Testing if the student can see another team is not covered here
    # Manually attempt to go to the filling in page
    expect{
      visit "/assessments/#{a.id}/fill_in"
    }.to raise_error ActionController::RoutingError

    # Manually submitting a POST request to the submission url should also fail
    expect {
      page.driver.submit :post, "/assessments/#{a.id}/process", {}
    }.to raise_error ActionController::RoutingError
  end

end

describe 'Viewing assessment results' do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    # Make assessment close tomorrow to prevent looking at results early
    a = create :assessment, uni_module: mod, date_closed: Date.today + 1

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

  specify 'I can view peer assessment results as a student only once the closing date has passed' do
    student = User.where(username: 'zzz12ac').first
    login_as student

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
      # The results button should be disabled, so RSpec can't see it
      expect(row).to have_content "Results"
      click_button "Results"
    }

  end

  specify "As a student I cannot see another student's grade"
  specify "As staff I can see all student's individual grades"
  specify 'As staff I can see individual student responses to the assessment'
  specify 'As a student I cannot see the individual student responses to the assessment'
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
