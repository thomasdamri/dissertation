require "rails_helper"
require "cancan/matchers"

describe 'Creating a work log' do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    t = create :team, uni_module: mod
    t2 = create :team, uni_module: mod, number: 2

    s1 = create :user, staff: false, username: "zzz12yu", email: "1@gmail.com"
    s2 = create :user, staff: false, username: "zzz12yh", email: "2@gmail.com"

    create :student_team, team: t, user: s1
    create :student_team, team: t, user: s2
  end

  specify "As a student I can write 1 work log for a given week and module", js: true do
    student = User.where(staff: false).first
    login_as student, scope: :user
    ability = Ability.new(student)

    t = student.teams.first

    expect(ability).to be_able_to :new_worklog, t
    expect(ability).to be_able_to :process_worklog, t

    visit "/teams/#{t.id}"
    click_link "Fill in work log for week"

    within(:css, '.modal-body'){
      # Test for blank submission
      click_button "Submit"
      # If the form submits while blank, the field will disappear and cause an error on this line
      fill_in 'content', with: 'A quick recap of work I did this week'
      click_button "Submit"
    }

    expect(page).to have_content "Work log uploaded successfully"

    expect(page).to_not have_content "Fill in work log for week"

  end

  specify "As a member of staff I cannot write a work log" do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    mod = UniModule.first
    t = mod.teams.first

    expect(ability).to_not be_able_to :new_worklog, t
    expect(ability).to_not be_able_to :process_worklog, t

    visit "/teams/#{t.id}"

    expect(page).to_not have_content 'Fill in work log for week'
  end

  specify "As a student I cannot submit a work log to a different team" do
    other_student = create :user, staff: false, username: "zzz12po", email: "5@gmail.com"
    login_as other_student, scope: :user
    ability = Ability.new(other_student)

    t = Team.first

    # User cannot view the team's page, so no point looking for button
    expect(ability).to_not be_able_to :new_worklog, t
    expect(ability).to_not be_able_to :process_worklog, t
  end

end

describe "Viewing all work logs" do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    t = create :team, uni_module: mod
    t2 = create :team, uni_module: mod, number: 2

    s1 = create :user, staff: false, username: "zzz12yu", email: "1@gmail.com"
    s2 = create :user, staff: false, username: "zzz12yh", email: "2@gmail.com"

    create :student_team, team: t, user: s1
    create :student_team, team: t, user: s2
  end

  specify "As a student I can view all the work logs my team have submitted", js: true do
    student = User.where(staff: false).first
    login_as student, scope: :user
    ability = Ability.new(student)

    mod = UniModule.first
    t = student.teams.first

    expect(ability).to be_able_to :display_worklogs, t

    last_monday = Date.today.monday? ? Date.today : Date.today.prev_occurring(:monday)

    w1 = create :worklog, uni_module: mod, author: student, fill_date: last_monday, content: "qwerty"
    w2 = create :worklog, uni_module: mod, author: User.where(username: "zzz12yh").first, fill_date: last_monday, content: "Hello"

    w3 = create :worklog, uni_module: mod, author: student, fill_date: last_monday.prev_occurring(:monday), content: "something"

    visit "/teams/#{t.id}"

    click_link 'View past work logs'

    click_link "Week beginning: #{last_monday.strftime("%d/%m/%Y")}"

    # Can only see the work logs from the past week
    within(:css, '.modal-body'){
      expect(page).to have_content w1.content
      expect(page).to have_content w2.content

      expect(page).to_not have_content w3.content
    }
  end

  specify "As a member of staff I can view all the work logs each team on a module have submitted" do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    mod = UniModule.first

    mod.teams.each do |t|
      expect(ability).to be_able_to :display_worklogs, t
    end

    # Can't view worklogs for a module I'm not associated with
    mod2 = create :uni_module, name: "Something else", code: "TEST1002"
    t2 = create :team, uni_module: mod2

    expect(ability).to_not be_able_to :display_worklogs, t2
  end

  specify "As a student I cannot view work logs from another team" do
    student = User.where(staff: false).first
    login_as student, scope: :user
    ability = Ability.new(student)

    mod = UniModule.first
    t = mod.teams.where(number: 2).first

    expect(ability).to_not be_able_to :display_worklogs, t

  end
end

describe 'Responding to a work log' do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    t = create :team, uni_module: mod
    t2 = create :team, uni_module: mod, number: 2

    s1 = create :user, staff: false, username: "zzz12yu", email: "1@gmail.com", display_name: "John Smith"
    s2 = create :user, staff: false, username: "zzz12yh", email: "2@gmail.com", display_name: "John Sith"

    create :student_team, team: t, user: s1
    create :student_team, team: t, user: s2

    last_monday = Date.today.monday? ? Date.today : Date.today.prev_occurring(:monday)
    create :worklog, author: s2, uni_module: mod, fill_date: last_monday
  end

  specify "As a student I can accept a work log from someone on my team" do
    # This student will review the work log
    student = User.where(username: "zzz12yu").first
    # This student wrote the work log
    target_student = User.where(username: "zzz12yh").first
    login_as student, scope: :user
    ability = Ability.new(student)

    mod = UniModule.first
    t = mod.teams.where(number: 1).first
    wl = Worklog.first

    expect(ability).to be_able_to :accept_worklog, wl

    # Should be no responses
    expect(WorklogResponse.count).to eq 0

    visit "/teams/#{t.id}"
    click_link "Review team work logs"
    row = page.find('tr', text: target_student.real_display_name)

    within(row){
      # Expect to see worklog content in the same row as the author
      expect(page).to have_content wl.content
      click_button "Accept"
    }

    # Should now be a response for this worklog
    resp = WorklogResponse.where(worklog: wl, user: student).first
    expect(resp.status).to eq WorklogResponse.accept_status
  end

  specify "As a student I can dispute a work log from someone on my team", js: true do
    # This student will review the work log
    student = User.where(username: "zzz12yu").first
    # This student wrote the work log
    target_student = User.where(username: "zzz12yh").first
    login_as student, scope: :user
    ability = Ability.new(student)

    mod = UniModule.first
    t = mod.teams.where(number: 1).first
    wl = Worklog.first

    expect(ability).to be_able_to :dispute_form, wl
    expect(ability).to be_able_to :dispute_worklog, wl

    # Should be no responses
    expect(WorklogResponse.count).to eq 0

    visit "/teams/#{t.id}"
    click_link "Review team work logs"
    row = page.find('tr', text: target_student.real_display_name)

    within(row){
      # Expect to see worklog content in the same row as the author
      expect(page).to have_content wl.content
      click_button "Dispute"
    }

    within(:css, '.modal-body'){
      fill_in 'reason', with: 'Dispute reason blah blah blah'
      click_button "Confirm Dispute"
    }

    # Should now be a response for this worklog
    resp = WorklogResponse.where(worklog: wl, user: student).first
    expect(resp.status).to eq WorklogResponse.reject_status
  end

  specify "As a member of staff I can see the review page, but not respond to a work log" do
    staff = User.where(staff: true).first
    # This student wrote the work log
    target_student = User.where(username: "zzz12yh").first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    mod = UniModule.first
    t = mod.teams.where(number: 1).first
    wl = Worklog.first

    expect(ability).to_not be_able_to :dispute_form, wl
    expect(ability).to_not be_able_to :dispute_worklog, wl

    visit "/teams/#{t.id}"
    click_link "Review team work logs"
    row = page.find('tr', text: target_student.real_display_name)

    within(row){
      # Expect to see worklog content in the same row as the author, but no buttons to respond
      expect(page).to have_content wl.content
      expect(page).to_not have_content "Accept"
      expect(page).to_not have_content "Dispute"
    }
  end

  specify "As a student I cannot respond to a work log more than once" do
    # This student will review the work log
    student = User.where(username: "zzz12yu").first
    # This student wrote the work log
    target_student = User.where(username: "zzz12yh").first
    login_as student, scope: :user
    ability = Ability.new(student)

    mod = UniModule.first
    t = mod.teams.where(number: 1).first
    wl = Worklog.first

    expect(ability).to be_able_to :accept_worklog, wl

    # Should be no responses
    expect(WorklogResponse.count).to eq 0

    visit "/teams/#{t.id}"
    click_link "Review team work logs"
    row = page.find('tr', text: target_student.real_display_name)

    within(row){
      # Expect to see worklog content in the same row as the author
      expect(page).to have_content wl.content
      click_button "Accept"
    }

    # Should now be a response for this worklog
    resp = WorklogResponse.where(worklog: wl, user: student).first
    expect(resp.status).to eq WorklogResponse.accept_status

    # Now the accept and dispute buttons should be greyed out
    row = page.find('tr', text: target_student.real_display_name)

    within(row){
      # Expect to see worklog content in the same row as the author
      expect(page).to have_content wl.content
      expect(page).to_not have_content "Accept"
      expect(page).to_not have_content "Dispute"
    }
  end

  specify "As a student I cannot respond to a work log once it has been resolved" do
    # This student will review the work log
    student = User.where(username: "zzz12yu").first
    # This student wrote the work log
    target_student = User.where(username: "zzz12yh").first
    login_as student, scope: :user
    ability = Ability.new(student)

    mod = UniModule.first
    t = mod.teams.where(number: 1).first
    wl = Worklog.first

    expect(ability).to be_able_to :accept_worklog, wl

    # Should be no responses
    expect(WorklogResponse.count).to eq 0

    visit "/teams/#{t.id}"
    click_link "Review team work logs"
    row = page.find('tr', text: target_student.real_display_name)


    # Create a resolved response for the worklog
    resp = create :worklog_response, user: target_student, worklog: wl, status: WorklogResponse.resolved_status

    # Now the accept and dispute buttons should be greyed out
    row = page.find('tr', text: target_student.real_display_name)

    within(row){
      # Expect to see worklog content in the same row as the author
      expect(page).to have_content wl.content
      expect(page).to_not have_content "Accept"
      expect(page).to_not have_content "Dispute"
    }
  end
end

describe 'Staff reviewing a work log' do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    t = create :team, uni_module: mod
    t2 = create :team, uni_module: mod, number: 2

    s1 = create :user, staff: false, username: "zzz12yu", email: "1@gmail.com", display_name: "John Smith"
    s2 = create :user, staff: false, username: "zzz12yh", email: "2@gmail.com", display_name: "John Sith"

    create :student_team, team: t, user: s1
    create :student_team, team: t, user: s2

    last_monday = Date.today.monday? ? Date.today : Date.today.prev_occurring(:monday)
    wl = create :worklog, author: s2, uni_module: mod, fill_date: last_monday
    create :worklog_response, worklog: wl, user: s1, status: WorklogResponse.reject_status
  end

  specify "As a member of staff on the module I can view the list of disputed work logs and uphold one" do
    staff = User.where(staff: true).first
    login_as staff, scope: :user
    ability = Ability.new(staff)

    mod = UniModule.first
    t = mod.teams.first

    visit "/uni_modules/#{mod.id}"
    click_link "View Disputes"
  end

  specify "As a member of staff on the module I can override a work log with a new value"

  specify "As a member of staff not on the module I cannot view or resolve any work log disputes"

  specify "As a student I cannot resolve a work log dispute"
end
