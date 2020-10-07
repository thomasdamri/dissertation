require 'rails_helper'

describe 'Adding users' do
  specify 'I can create users from a csv file, assign them a team, then login as a created user' do
    # Create staff user and login
    staff = create(:user, staff: true)
    login_as staff, scope: :user
    # Upload a csv of user information
    visit '/upload/users'
    attach_file 'spec/uploads/users.csv'
    click_button 'Import'
    # Create module
    mod = create(:uni_module)
    staff_mod = create(:staff_module, user: staff, uni_module: mod)
    # Assign teams to each user
    visit '/upload/teams/' + mod.id.to_s
    attach_file 'spec/uploads/teams.csv'
    click_button 'Import'
    # Log in as user in team 1, check I can see that team
    u1 = User.find_by_username('zzz12tu')
    login_as u1, scope: :user
    visit home_student_home_url
    within(:css, '#teams'){
      expect(page).to have_content mod.name + " - Team 1"
    }
    # Repeat with team 2
    u2 = User.find_by_username('zzv12tu')
    login_as u2, scope: :user
    visit home_student_home_url
    within(:css, '#teams'){
      expect(page).to have_content mod.name + " - Team 2"
    }
  end

end
