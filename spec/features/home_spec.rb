require "rails_helper"

describe "Viewing the My Account page" do
  specify "My personal information is correct" do
    u = create :user, staff: false, username: "acc17dp", email: "dperry1@sheffield.ac.uk", display_name: "Dan Perry"
    login_as u, scope: :user

    visit "/home/account"

    within(:css, '#accInfo'){
      expect(page).to have_content "acc17dp"
      expect(page).to have_content "dperry1@sheffield.ac.uk"
      expect(page).to have_content "Student"
      expect(page).to have_content "Dan Perry"
    }

    u.staff = true
    u.save

    visit "/home/account"

    within(:css, '#accInfo'){
      expect(page).to have_content "Staff"
    }

    u.admin = true
    u.save

    visit "/home/account"

    within(:css, '#accInfo'){
      expect(page).to have_content "Staff (Admin)"
    }
  end

end

describe "Viewing the student dashboard" do
  before(:each) do
    u = create :user, staff: false
    mod = create :uni_module
    t = create :team, uni_module: mod
    create :student_team, user: u, team: t
  end

  specify "The badge colours for students' assessments are correct", js: true do
    u = User.first
    login_as u, scope: :user

    mod = UniModule.first

    visit "/home/student_home"

    # Find the list item for the module
    li = nil
    within(:css, '#modInfo'){
      li = page.find('li', text: mod.title)
    }

    within(li){
      # Find span element to expand assessment list
      span = page.find('span', text: 'Show Assessments')
      span.click
      expect(page).to have_content "This module has no assessments"
    }

    a = create :assessment, uni_module: mod, date_opened: Date.today + 1, date_closed: Date.today + 2
    c = create :criterium, assessment: a

    # Test a future assessment (open day tomorrow)
    page.driver.browser.navigate.refresh

    # Find the list item for the module
    li = nil
    within(:css, '#modInfo'){
      li = page.find('li', text: mod.title)
    }

    assess_li = nil
    within(li){
      # Find span element to expand assessment list
      span = page.find('span', text: 'Show Assessments')
      span.click
      assess_li = page.find('li', text: a.name)
    }

    within(assess_li){
      expect(page).to have_content "Not Open"
    }

    # Test an open incomplete assessment (open date today)
    a.date_opened = Date.today
    a.save
    page.driver.browser.navigate.refresh

    # Find the list item for the module
    li = nil
    within(:css, '#modInfo'){
      li = page.find('li', text: mod.title)
    }

    assess_li = nil
    within(li){
      # Find span element to expand assessment list
      span = page.find('span', text: 'Show Assessments')
      span.click
      assess_li = page.find('li', text: a.name)
    }

    within(assess_li){
      expect(page).to have_content "Open"
    }

    # Test an open incomplete assessment (close date today)
    a.date_closed = Date.today
    a.save
    page.driver.browser.navigate.refresh

    # Find the list item for the module
    li = nil
    within(:css, '#modInfo'){
      li = page.find('li', text: mod.title)
    }

    assess_li = nil
    within(li){
      # Find span element to expand assessment list
      span = page.find('span', text: 'Show Assessments')
      span.click
      assess_li = page.find('li', text: a.name)
    }

    within(assess_li){
      expect(page).to_not have_content "Not Open"
      expect(page).to have_content "Open"
    }

    # Test an open completed assessment
    create :assessment_result, criterium: c, author: u, value: "Test Answer"
    page.driver.browser.navigate.refresh

    # Find the list item for the module
    li = nil
    within(:css, '#modInfo'){
      li = page.find('li', text: mod.title)
    }

    assess_li = nil
    within(li){
      # Find span element to expand assessment list
      span = page.find('span', text: 'Show Assessments')
      span.click
      assess_li = page.find('li', text: a.name)
    }

    within(assess_li){
      expect(page).to have_content "Completed"
    }

    # Test a closed assessment with show_results as false
    a.show_results = false
    a.date_opened = Date.today - 2
    a.date_closed = Date.today - 1
    a.save
    page.driver.browser.navigate.refresh

    # Find the list item for the module
    li = nil
    within(:css, '#modInfo'){
      li = page.find('li', text: mod.title)
    }

    assess_li = nil
    within(li){
      # Find span element to expand assessment list
      span = page.find('span', text: 'Show Assessments')
      span.click
      assess_li = page.find('li', text: a.name)
    }

    within(assess_li){
      expect(page).to have_content "Awaiting Results"
    }

    # Test a closed assessment with show_results as true
    a.show_results = true
    a.save
    page.driver.browser.navigate.refresh

    # Find the list item for the module
    li = nil
    within(:css, '#modInfo'){
      li = page.find('li', text: mod.title)
    }

    assess_li = nil
    within(li){
      # Find span element to expand assessment list
      span = page.find('span', text: 'Show Assessments')
      span.click
      assess_li = page.find('li', text: a.name)
    }

    within(assess_li){
      expect(page).to have_content "Results Ready"
    }

  end

  specify "The colours of the badges for work logs are correct" do
    u = User.first
    mod = UniModule.first

    login_as u, scope: :user

    visit "/home/student_home"

    within(:css, '#worklogInfo'){
      li = page.find('li', text: mod.title)
      expect(li).to have_content "Pending"
    }

    last_mon = Date.today.monday? ? Date.today : Date.today.prev_occurring(:monday)
    create :worklog, uni_module: mod, author: u, fill_date: last_mon

    visit "/home/student_home"

    within(:css, '#worklogInfo'){
      li = page.find('li', text: mod.title)
      expect(li).to have_content "Filled in"
    }

  end
end

describe "Viewing the staff dashboard" do
  before(:each) do
    staff1 = create :user, staff: true, username: "zzz12pl", email: "p@gmail.com"
    staff2 = create :user, staff: true, username: "zzz12lp", email: "l@gmail.com"
    staff3 = create :user, staff: true, username: "zzz12ui", email: "u@gmail.com"
    staff4 = create :user, staff: true, username: "zzz12rh", email: "r@gmail.com"

    # Create two modules, two teams per module, two students per team
    mod = create :uni_module, code: "COM1004"
    mod2 = create :uni_module, code: "COM1005", name: "Something"

    create :staff_module, user: staff1, uni_module: mod
    create :staff_module, user: staff2, uni_module: mod2
    create :staff_module, user: staff3, uni_module: mod
    create :staff_module, user: staff3, uni_module: mod2

    t11 = create :team, uni_module: mod
    t12 = create :team, uni_module: mod, number: 2
    t21 = create :team, uni_module: mod2
    t22 = create :team, uni_module: mod2, number: 2

    u111 = create :user, staff: false, username: "zzz12aa", email: "a@gmail.com"
    u112 = create :user, staff: false, username: "zzz12ab", email: "b@gmail.com"
    u121 = create :user, staff: false, username: "zzz12ac", email: "c@gmail.com"
    u122 = create :user, staff: false, username: "zzz12ad", email: "d@gmail.com"
    u211 = create :user, staff: false, username: "zzz12ae", email: "e@gmail.com"
    u212 = create :user, staff: false, username: "zzz12af", email: "f@gmail.com"
    u221 = create :user, staff: false, username: "zzz12ag", email: "g@gmail.com"
    u222 = create :user, staff: false, username: "zzz12ah", email: "h@gmail.com"

    create :student_team, team: t11, user: u111
    create :student_team, team: t11, user: u112
    create :student_team, team: t12, user: u121
    create :student_team, team: t12, user: u122
    create :student_team, team: t21, user: u211
    create :student_team, team: t21, user: u212
    create :student_team, team: t22, user: u221
    create :student_team, team: t22, user: u222

    # Create some worklogs
    # Module 1 has both teams 1 and 2 with outstanding logs
    # Module 2 has only team 2 with outstanding logs
    w1 = create :worklog, author: u111, uni_module: mod, content: "Something1"
    create :worklog_response, worklog: w1, user: u112, status: WorklogResponse.reject_status
    w2 = create :worklog, author: u121, uni_module: mod, content: "Something2"
    create :worklog_response, worklog: w2, user: u122, status: WorklogResponse.reject_status
    w3 = create :worklog, author: u122, uni_module: mod, content: "Something3"
    create :worklog_response, worklog: w3, user: u121, status: WorklogResponse.reject_status
    w4 = create :worklog, author: u221, uni_module: mod, content: "Something4"
    create :worklog_response, worklog: w4, user: u222, status: WorklogResponse.reject_status

  end

  specify "I can only see modules I am associated with", js: true do
    staff1 = User.where(username: "zzz12pl").first
    staff2 = User.where(username: "zzz12lp").first
    staff3 = User.where(username: "zzz12ui").first
    staff4 = User.where(username: "zzz12rh").first

    mod1 = UniModule.where(code: "COM1004").first
    mod2 = UniModule.where(code: "COM1005").first

    # Staff1 can only see module 1
    login_as staff1, scope: :user
    visit "/home/staff_home"

    within(:css, '#modInfo'){
      expect(page).to have_content mod1.title
      expect(page).to_not have_content mod2.title
    }

    # Staff2 can only see module 2
    login_as staff2, scope: :user
    visit "/home/staff_home"

    within(:css, '#modInfo'){
      expect(page).to have_content mod2.title
      expect(page).to_not have_content mod1.title
    }

    # Staff3 can see both modules
    login_as staff3, scope: :user
    visit "/home/staff_home"

    within(:css, '#modInfo'){
      expect(page).to have_content mod1.title
      expect(page).to have_content mod2.title
    }

    # Staff4 cannot see any modules
    login_as staff4, scope: :user
    visit "/home/staff_home"

    within(:css, '#modInfo'){
      expect(page).to have_content "You are not currently involved in any modules"
      expect(page).to_not have_content mod1.title
      expect(page).to_not have_content mod2.title
    }
  end

  specify "I can only see teams in modules I am associated with, and have active disputes" do
    staff1 = User.where(username: "zzz12pl").first
    staff2 = User.where(username: "zzz12lp").first
    staff3 = User.where(username: "zzz12ui").first
    staff4 = User.where(username: "zzz12rh").first

    mod1 = UniModule.where(code: "COM1004").first
    mod2 = UniModule.where(code: "COM1005").first

    # Can see module 1's worklogs - team 1 and 2
    login_as staff1, scope: :user
    visit "/home/staff_home"

    within(:css, '#logInfo'){
      expect(page).to have_content "#{mod1.code} - Team 1"
      expect(page).to have_content "#{mod1.code} - Team 2"
      expect(page).to_not have_content "#{mod2.code} - Team 2"
    }

    # Can see module 2's worklogs - just team 2
    login_as staff2, scope: :user
    visit "/home/staff_home"

    within(:css, '#logInfo'){
      expect(page).to have_content "#{mod2.code} - Team 2"
      expect(page).to_not have_content "#{mod1.code} - Team 1"
    }

    # Can see both modules' worklogs
    login_as staff3, scope: :user
    visit "/home/staff_home"

    within(:css, '#logInfo'){
      expect(page).to have_content "#{mod1.code} - Team 1"
      expect(page).to have_content "#{mod1.code} - Team 2"
      expect(page).to have_content "#{mod2.code} - Team 2"
      expect(page).to_not have_content "#{mod2.code} - Team 1"
    }

    # Can see no modules' worklogs
    login_as staff4, scope: :user
    visit "/home/staff_home"

    within(:css, '#logInfo'){
      expect(page).to have_content "You do not have any unresolved disputes"
      expect(page).to_not have_content "#{mod1.code} - Team 1"
      expect(page).to_not have_content "#{mod2.code} - Team 1"
    }

  end
end
