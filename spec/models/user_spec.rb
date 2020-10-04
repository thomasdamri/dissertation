require 'rails_helper'

RSpec.describe User, type: :model do

  it 'is valid with a username, email address, and staff + admin booleans' do
    u = build(:user)
    expect(u).to be_valid
  end

  it 'is invalid with blank attributes' do
    u = build(:blank_user)
    expect(u).to_not be_valid
  end

  it 'is invalid with a non-unique username or email address' do
    u1 = create(:user)
    expect(u1).to be_valid

    u2 = build(:user)
    expect(u2).to_not be_valid

    u2.username = 'zzy12dp'
    expect(u2).to_not be_valid

    u2.email = "dperry2@sheffield.ac.uk"
    expect(u2).to be_valid

  end

  it 'is invalid with an invalid email address' do
    u = build(:user, email: 'fjeiwvn')
    expect(u).to_not be_valid
  end

end
