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
    student = create(:user)
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
  specify 'I can fill in an assessment if I am a student who is on the module'
  specify 'I cannot fill in an assessment as a staff member on the module'
  specify 'I cannot fill in an assessment as a student on a different module'
  specify 'I can only fill in an assessment once'
  specify 'I cannot leave fields in the assessment blank and have it be valid'
end

describe 'Viewing assessment results' do
  specify 'I can view peer assessment results as a student only once the closing date has passed'
  specify "As a student I cannot see another student's results"
  specify 'As staff I can see individual student responses to the assessment'
end
