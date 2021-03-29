require "rails_helper"
require "cancan/matchers"

describe "Changing my own name" do
  before(:each) do
    u = create :user, display_name: "Fred"
  end

  specify "I can change my own name", js: true do
    u = User.first
    login_as u, scope: :user

    visit "/home/account"
    old_name = u.display_name
    new_name = "James Holden"

    click_link "Change Name"

    fill_in "New name", with: new_name
    click_button "Change Name"

    expect(page).to have_content new_name
    expect(page).to_not have_content old_name
  end

  specify "I cannot change another students name, as a non-admin"

  specify "I cannot change my name to an empty value", js: true do
    u = User.first
    login_as u, scope: :user

    visit "/home/account"
    old_name = u.display_name

    click_link "Change Name"

    fill_in "New name", with: ""
    click_button "Change Name"

    expect(page).to have_content "Error: Name was empty, could not update"
    expect(page).to have_content old_name
  end

  specify "I cannot change my name to a value that is too long", js: true do
    u = User.first
    login_as u, scope: :user

    visit "/home/account"
    old_name = u.display_name
    new_name = "A" * (User.max_display_name_length + 1)

    click_link "Change Name"

    fill_in "New name", with: new_name
    click_button "Change Name"

    expect(page).to_not have_content new_name
    expect(page).to have_content old_name
    expect(page).to have_content "Error: Could not save name change. Are you sure it does not exceed 250 characters?"
  end
end

describe "Changing another user's name" do
  specify "I can change another user's name as an admin"
end
