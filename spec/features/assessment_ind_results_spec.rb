require "rails_helper"
require "cancan/matchers"

describe 'Viewing and modifying assessment results' do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    # Make assessment close tomorrow to prevent looking at results early
    a = create :assessment, uni_module: mod, date_closed: Date.today + 1

    c = create :weighted_criteria, assessment: a
    c2 = create :criteria, assessment: a, title: 'Something else'

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

    create :assessment_result_empty, author: u1, target: u1, criteria: c, value: '7'
    create :assessment_result_empty, author: u1, target: u2, criteria: c, value: '8'
    create :assessment_result_empty, author: u1, target: u3, criteria: c, value: '9'
    create :assessment_result_empty, author: u1, target: u4, criteria: c, value: '7'

    create :assessment_result_empty, author: u1, target: nil, criteria: c2, value: 'Some text'

    a.generate_weightings(t)
  end

  specify 'I can view my assessment results as a student only once the closing date has passed', js: true do
    student = User.where(username: 'zzz12ac').first
    login_as student, scope: :user

    t = Team.first
    a = Assessment.first

    # Set show_results to true, as I am only testing the dates in this test
    a.show_results = true
    a.save

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

  specify 'As a member of staff I can toggle whether students can see their grades', js: true do
    student = User.where(username: 'zzz12ac').first
    login_as student, scope: :user
    ability = Ability.new(student)

    t = Team.first
    a = Assessment.first
    # Set the date of the assessment to the previous day, so that the date_closed doesnt matter
    a.date_closed = Date.yesterday
    a.save
    # Reloading the assessment from the db, because sometimes caching is a pain
    a = Assessment.first
    # By default, the assessment should not show results to students
    expect(a.show_results).to eq false

    # Quick permissions check - student cannot set show_results
    expect(ability).to_not be_able_to :toggle_results, a

    visit "/teams/#{t.id}"

    tr = page.first('tr', text: a.name)
    row = tr.find(:xpath, '..')

    within(row){
      # The results button should be disabled, so RSpec can't see it
      expect(row).to_not have_content "Results"
    }

    # Login as a staff member and change the show_results attribute to true
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    # Associated staff member can toggle the value of show_results
    expect(ability).to be_able_to :toggle_results, a

    visit "/assessment/#{a.id}"

    # Set show_results to false
    within(:css, '#gradeTools'){
      click_button "Show students their grade"
    }

    # After changing, log back in as student
    login_as student, scope: :user
    visit "/teams/#{t.id}"

    tr = page.first('tr', text: a.name)
    row = tr.find(:xpath, '..')

    within(row){
      # The results button is now visible - click it
      click_button "Results"
    }

    # Not re-checking the contents of the modal, as this was done in previous test
    within(:css, '#resultsModal'){
      expect(page).to have_content "Team grade:"
    }


    # Finally just check an unassociated staff member cannot toggle show_results
    other_staff = create :user, staff: false, username: "zzz12mj", email: "123@gmail.com"
    ability = Ability.new(other_staff)
    expect(ability).to_not be_able_to :toggle_results, a
  end

  specify "As staff I can see all student's individual grades", js: true  do
    staff = User.where(staff: true).first
    login_as staff, scope: :user

    t = Team.first
    a = Assessment.first

    visit "/assessment/#{a.id}"

    click_link 'View Individual Grades'

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
          ar = AssessmentResult.where(criteria: crit).first
          expect(page).to have_content ar.value
        else
          # If criteria is not single, search for the response targeting each user
          t.users.each do |u|
            ar = AssessmentResult.where(target: u, criteria: crit).first
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
end

describe "Downloading results" do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod

    a = create :assessment, uni_module: mod

    c = create :weighted_criteria, assessment: a

    u1 = create :user, staff: false, username: 'zzz12ac', email: 'something@gmail.com'
    u2 = create :user, staff: false, username: 'zzz12ad', email: 'something2@gmail.com'
    u3 = create :user, staff: false, username: 'zzz12ae', email: 'something3@gmail.com'
    u4 = create :user, staff: false, username: 'zzz12af', email: 'something4@gmail.com'

    t = create :team, uni_module: mod

    create :student_team, user: u1, team: t
    create :student_team, user: u2, team: t
    create :student_team, user: u3, team: t
    create :student_team, user: u4, team: t

    create :assessment_result_empty, author: u1, target: u1, criteria: c, value: '7'
    create :assessment_result_empty, author: u1, target: u1, criteria: c, value: '8'
    create :assessment_result_empty, author: u1, target: u1, criteria: c, value: '9'
    create :assessment_result_empty, author: u1, target: u1, criteria: c, value: '7'

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
