# == Schema Information
#
# Table name: staff_modules
#
#  id            :bigint           not null, primary key
#  user_id       :bigint
#  uni_module_id :bigint
#
require 'rails_helper'

RSpec.describe StudentWeighting, type: :model do
  before(:each) do
    create :uni_module
    create :user, staff: true
  end

  it 'is valid to link a staff member to a module' do
    mod = UniModule.first
    staff = User.first
    sm = build :staff_module, uni_module: mod, user: staff
    expect(sm).to be_valid
  end

  it 'is invalid to assign the same staff member to the same module twice' do
    mod = UniModule.first
    staff = User.first
    sm = create :staff_module, uni_module: mod, user: staff
    sm2 = build :staff_module, uni_module: mod, user: staff
    expect(sm2).to_not be_valid
  end

end