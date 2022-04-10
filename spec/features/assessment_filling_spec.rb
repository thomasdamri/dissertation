require "rails_helper"
require "cancan/matchers"

describe 'Filling in an assessment' do
  # Setup an assessment to fill in and a team to be in
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    a = create :assessment, uni_module: mod
    create :criteria, assessment: a, title: 'Test 1', response_type: 1, min_value: 1, max_value: 10
    create :criteria, assessment: a, title: 'Test 2', response_type: 1, single: false, min_value: 1, max_value: 10

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

  specify 'I can only fill in an assessment during the set period of time' do
    student = User.where(username: 'zzz12ac').first
    login_as student, scope: :user

    t = Team.first
    a = Assessment.first

    # First test when before open date
    a.date_opened = Date.tomorrow
    a.date_closed = Date.tomorrow + 7
    a.save

    visit "/teams/#{t.id}"

    # Should be able to see assessment in the table
    expect(page).to have_content a.name
    tr = page.first('tr', text: a.name)
    row = tr.find(:xpath, '..')

    within(row){
      expect(page).to_not have_content "Fill In"
    }
    # Expect a redirect
    visit "/assessment/#{a.id}/fill_in"
    expect(page).to have_content "Group Email Info"

    # Now test when after close date
    a.date_opened = Date.yesterday - 7
    a.date_closed = Date.yesterday
    a.save

    visit "/teams/#{t.id}"

    # Should be able to see assessment in the table
    expect(page).to have_content a.name
    tr = page.first('tr', text: a.name)
    row = tr.find(:xpath, '..')

    within(row){
      expect(page).to_not have_content "Fill In"
    }
    # Expect a redirect
    visit "/assessment/#{a.id}/fill_in"
    expect(page).to have_content "Group Email Info"

    # Now try with a correct date
    a.date_opened = Date.yesterday
    a.date_closed = Date.tomorrow
    a.save

    visit "/teams/#{t.id}"

    # Should be able to see assessment in the table
    expect(page).to have_content a.name
    tr = page.first('tr', text: a.name)
    row = tr.find(:xpath, '..')

    within(row){
      expect(page).to have_content "Fill In"
    }
    # Expect a redirect
    visit "/assessment/#{a.id}/fill_in"
    expect(page).to_not have_content "Group Email Info"
    expect(page).to have_content a.name
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
    create :criteria, assessment: a, title: 'Test 1', response_type: 0
    create :criteria, assessment: a, title: 'Test 2', response_type: 1, min_value: 1, max_value: 10
    create :criteria, assessment: a, title: 'Test 3', response_type: 2, min_value: 1.1, max_value: 10.1
    create :criteria, assessment: a, title: 'Test 4', response_type: 3, min_value: "No", max_value: "Yes"

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
        if crit.response_type == Criteria.string_type
          fill_in "response_#{crit.id}", with: "String response"
        elsif crit.response_type == Criteria.int_type
          fill_in "response_#{crit.id}", with: "1"
        elsif crit.response_type == Criteria.float_type
          fill_in "response_#{crit.id}", with: "4.5"
        elsif crit.response_type == Criteria.bool_type
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

  specify "I am able to re-submit if one of my responses is too large" do
    t = Team.first
    mod = UniModule.first

    student = t.users.first
    login_as student, scope: :user

    a = create :assessment, uni_module: mod, name: "All data types test"
    c = create :criteria, assessment: a, title: 'Test 1', response_type: 0

    val1 = "a" * (AssessmentResult.max_value_length + 1)
    val2 = "a" * AssessmentResult.max_value_length

    visit "/assessment/#{a.id}/fill_in"
    fill_in "response_#{c.id}", with: val1

    click_button "Submit"
    expect(page).to have_content "An error occurred. Are all your responses 250 characters or shorter?"
    expect(AssessmentResult.count).to eq 0

    # Have to re-visit the page, as the text box still has the old contents in it
    visit "/assessment/#{a.id}/fill_in"
    fill_in "response_#{c.id}", with: val2
    click_button "Submit"
    expect(page).to_not have_content "An error occurred. Are all your responses 250 characters or shorter?"
    expect(AssessmentResult.count).to eq 1
  end
end

describe "Assessment mock view" do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    a = create :assessment, uni_module: mod
    create :criteria, assessment: a, title: 'Test 1', response_type: 1, min_value: 1, max_value: 10
    create :criteria, assessment: a, title: 'Test 2', response_type: 1, single: false, min_value: 1, max_value: 10

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

  specify "I can see the mock view of this assessment as a staff member on the module, when there are teams" do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)
    a = Assessment.first

    expect(ability).to be_able_to :mock_view, a

    visit "/assessment/#{a.id}"
    click_link "Show Student View"

    a.criteria.each do |crit|
      expect(page).to have_content crit.title
    end
  end

  specify "I cannot see the mock view of the assessment when there are no teams uploaded" do
    # First remove all the teams
    a = Assessment.first
    a.uni_module.teams.each do |t|
      t.destroy
    end

    staff = User.where(staff: true).first
    login_as staff, scope: :user

    visit "/assessment/#{a.id}"
    expect(page).to_not have_content "Show Student View"
  end

  specify "I cannot see the mock view as an unassociated staff member or a student" do
    t = Team.first
    student = t.users.first
    other_staff = create :user, staff: true, username: "zzz12bg", email: "lkj@gmail.com"
    ability = Ability.new(student)
    ability2 = Ability.new(other_staff)
    a = Assessment.first

    expect(ability).to_not be_able_to :mock_view, a
    expect(ability2).to_not be_able_to :mock_view, a
  end

end
