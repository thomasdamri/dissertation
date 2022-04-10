require "rails_helper"
require "cancan/matchers"

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

  specify 'I can create an assessment with a criteria of every single type', js: true do
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

    # Add another decimal question, but with no min or max, and single answer
    click_link "Add Question - Decimal Number Response"

    input_box = page.all('.crit-input').last
    within(input_box){
      expect(page).to have_content "Decimal Number Response Question"
      fill_in "Field Title", with: "Decimal Question"
      choose "Single Answer"
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

  specify "I cannot create an assessment with criteria with a length exceeding the max length", js: true do
    # Create staff user and login
    staff = create(:user, staff: true)
    login_as staff, scope: :user
    # Create module associated with the user
    mod = create :uni_module
    create :staff_module, user: staff, uni_module:  mod
    # Visit page for creating new assessment for the module
    visit "/assessment/new/#{mod.id}"

    fill_in "Name", with: "This should fail"

    click_link "Add Question - Text Response"

    input_box = page.all('.crit-input').last
    within(input_box){
      expect(page).to have_content "Text Response Question"
      fill_in "Field Title", with: ("a" * (Criteria.max_title_length + 1))
      choose "Single Answer"
    }

    click_button "Create Assessment"

    expect(page).to have_content "Title is too long (maximum is 250 characters)"
    expect(page).to_not have_content "Assessment was successfully created."
  end

end

describe 'Editing an assessment' do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    a = create :assessment, uni_module: mod, show_results: true
  end

  specify 'I can edit an assessment if I am part of the module, and students are affected by the date change' do
    # By default, the assessment is open, as today falls within the open and close dates
    student = create :user, staff: false, username: "zzz12rf", email: "k@gmail.com"
    t = create :team, uni_module: UniModule.first
    create :student_team, user: student, team: t
    login_as student, scope: :user
    assess = Assessment.first

    visit "/teams/#{t.id}"
    row = nil
    within(:css, '#studentAssessTable'){
      row = page.first('tr', text: assess.name)
    }

    within(row){
      expect(page).to have_content "Fill In"
    }

    # Log in as a staff member to change the date
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    old_start_date = assess.date_opened
    old_end_date = assess.date_closed

    expect(ability).to be_able_to :edit, assess
    expect(ability).to be_able_to :update, assess

    visit "/assessment/#{assess.id}"
    click_link "Change Dates"

    select "2026", from: 'assessment_date_opened_1i'
    select "August", from: 'assessment_date_opened_2i'
    select "18", from: "assessment_date_opened_3i"
    new_open_date = Date.new(2026, 8, 18)

    select "2026", from: 'assessment_date_closed_1i'
    select "December", from: 'assessment_date_closed_2i'
    select "25", from: "assessment_date_closed_3i"
    new_close_date = Date.new(2026, 12, 25)

    click_button "Update Assessment"

    within(:css, '#assessDate'){
      expect(page).to have_content new_open_date.to_s
      expect(page).to have_content new_close_date.to_s
      expect(page).to_not have_content old_start_date.to_s
      expect(page).to_not have_content old_end_date.to_s
    }

    # Now the dates have changed, confirm a student can no longer fill in the assessment
    login_as student, scope: :user

    visit "/teams/#{t.id}"
    row = nil
    within(:css, '#studentAssessTable'){
      row = page.first('tr', text: assess.name)
    }

    within(row){
      expect(page).to_not have_content "Fill In"
    }

  end

  specify 'I cannot edit an assessment if I am a member of staff not associated with the module' do
    new_staff = create :user, staff: true, username: "zzz12er", email: "1@gmail.com"
    ability = Ability.new(new_staff)
    assess = Assessment.first

    expect(ability).to_not be_able_to :edit, assess
    expect(ability).to_not be_able_to :update, assess
  end

  specify 'I cannot edit an assessment if I am a student' do
    student = create :user, staff: false, username: "zzz12et", email: "2@gmail.com"
    ability = Ability.new(student)
    assess = Assessment.first

    expect(ability).to_not be_able_to :edit, assess
    expect(ability).to_not be_able_to :update, assess
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
    create :criteria, assessment: a

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
    create :criteria, assessment: a

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
    create :criteria, assessment: a

    # Student cannot even view the module page to find the delete button
    expect(ability).to_not be_able_to(:read, mod)
    # Student cannot delete the assessment
    expect(ability).to_not be_able_to(:delete, a)
  end
end
