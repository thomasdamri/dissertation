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

    t2.number = 2
    expect(t2).to be_valid

  end

end
