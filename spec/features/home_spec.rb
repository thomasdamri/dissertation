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
  specify "The badge colours for students' assessments are correct", js: true do
    u = create :user, staff: false
    login_as u, scope: :user

    mod = create :uni_module
    t = create :team, uni_module: mod
    create :student_team, user: u, team: t

    visit "/home/student_home"

    # Find the list item for the module
    li = page.find('li', text: mod.title)

    within(li){
      # Find span element to expand assessment list
      span = page.find('span', text: 'Show Assessments')
      span.click
      expect(page).to have_content "This module has no assessments"
    }

    a = create :assessment, uni_module: mod, date_opened: Date.today + 1, date_closed: Date.today + 2
    c = create :criterium, assessment: a

    # Test a future assessment
    page.driver.browser.navigate.refresh

    # Find the list item for the module
    li = page.find('li', text: mod.title)

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

    # Test an open incomplete assessment
    a.date_opened = Date.today - 1
    a.save
    page.driver.browser.navigate.refresh

    # Find the list item for the module
    li = page.find('li', text: mod.title)

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

    # Test an open completed assessment
    create :assessment_result, criterium: c, author: u, value: "Test Answer"
    page.driver.browser.navigate.refresh

    # Find the list item for the module
    li = page.find('li', text: mod.title)

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

    # Test a closed assessment
    a.date_closed = Date.today - 1
    a.save
    page.driver.browser.navigate.refresh

    # Find the list item for the module
    li = page.find('li', text: mod.title)

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
end
