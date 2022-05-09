# require "rails_helper"
# require "cancan/matchers"

# describe "Changing my own name" do
#   before(:each) do
#     u = create :user, display_name: "Fred"
#   end

#   specify "I can change my own name", js: true do
#     u = User.first
#     login_as u, scope: :user

#     visit "/home/account"
#     old_name = u.display_name
#     new_name = "James Holden"

#     click_link "Change Name"

#     fill_in "New name", with: new_name
#     click_button "Change Name"

#     expect(page).to have_content new_name
#     expect(page).to_not have_content old_name
#   end

#   specify "I cannot change my name to an empty value", js: true do
#     u = User.first
#     login_as u, scope: :user

#     visit "/home/account"
#     old_name = u.display_name

#     click_link "Change Name"

#     fill_in "New name", with: ""
#     click_button "Change Name"

#     expect(page).to have_content "Error: Name was empty, could not update"
#     expect(page).to have_content old_name
#   end

#   specify "I cannot change my name to a value that is too long", js: true do
#     u = User.first
#     login_as u, scope: :user

#     visit "/home/account"
#     old_name = u.display_name
#     new_name = "A" * (User.max_display_name_length + 1)

#     click_link "Change Name"

#     fill_in "New name", with: new_name
#     click_button "Change Name"

#     expect(page).to_not have_content new_name
#     expect(page).to have_content old_name
#     expect(page).to have_content "Error: Could not save name change. Are you sure it does not exceed 250 characters?"
#   end
# end

# describe "Changing another user's name" do
#   before(:each) do
#     create :user, admin: true, display_name: "Admin Joe"
#     create :user, staff: true, display_name: "Joe Miller", username: "zzz12ld", email: "d@gmail.com"
#     create :user, staff: false, display_name: "James Holden", username: "zzz12ed", email: "p@gmail.com"
#   end

#   specify "I can change a student's name as an admin", js: true do
#     admin = User.where(admin: true).first
#     puts "------"
#     login_as admin, scope: :user
#     visit "/admin/students"
#     click_link "Change Name"

#     student = User.where(staff: false).first
#     old_name = student.display_name
#     new_name = "Something New"

#     fill_in "New name", with: new_name
#     click_button "Change Name"

#     expect(page).to have_content new_name
#     expect(page).to_not have_content old_name
#   end

#   specify "I can change a staff member's name as an admin", js: true do
#     admin = User.where(admin: true).first
#     login_as admin, scope: :user
#     visit "/admin/staff"

#     staff = User.where(username: 'zzz12ld').first
#     row = page.find('tr', text: staff.username)

#     within(row){
#       click_link "Change Name"
#     }

#     old_name = staff.display_name
#     new_name = "Something New"

#     fill_in "New name", with: new_name
#     click_button "Change Name"

#     expect(page).to have_content new_name
#     expect(page).to_not have_content old_name
#   end

# end
