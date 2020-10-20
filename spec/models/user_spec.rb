# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  email              :string(255)      default(""), not null
#  sign_in_count      :integer          default(0), not null
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :string(255)
#  last_sign_in_ip    :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  username           :string(255)
#  uid                :string(255)
#  mail               :string(255)
#  ou                 :string(255)
#  dn                 :string(255)
#  sn                 :string(255)
#  givenname          :string(255)
#  display_name       :string(255)
#  reg_no             :integer
#  staff              :boolean
#  admin              :boolean
#
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
