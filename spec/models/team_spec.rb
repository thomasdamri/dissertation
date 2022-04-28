# == Schema Information
#
# Table name: teams
#
#  id            :bigint           not null, primary key
#  uni_module_id :bigint
#  number        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe User, type: :model do

  it 'is valid with a number' do
    u = create(:uni_module)

    t = build(:team, uni_module: u)
    expect(t).to be_valid
  end

  it 'is invalid without a number or module' do
    t = build(:blank_team)
    expect(t).to_not be_valid
  end

  it 'is invalid with a number shared with another team of the same module' do
    u = create(:uni_module)

    t1 = create(:team, uni_module: u)

    t2 = build(:team, uni_module: u)
    expect(t2).to_not be_valid

    t2.team_number = 2
    expect(t2).to be_valid

  end

end
