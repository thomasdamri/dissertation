require 'rails_helper'

RSpec.describe Criterium, type: :model do
  before :each do
    u = create :uni_module
    a = create :assessment, uni_module: u
  end

  it 'is valid with valid attributes' do
    # Get first assessment, created earlier to attach the criterium to
    a = Assessment.first
    # Create a non-assessed string type criteria
    c1 = build(:criterium, assessment: a)
    c2 = build(:weighted_criterium, assessment: a)

    expect(c1).to be_valid
    expect(c2).to be_valid
  end

  it 'is invalid with blank attributes' do
    c1 = build(:blank_criterium)
    expect(c1).to_not be_valid
  end

  it 'is invalid when max value is less than the min value' do
    c1 = build(:weighted_criterium, assessment: Assessment.first, min_value: 11)
    expect(c1).to_not be_valid
    c1.min_value = 1
    expect(c1).to be_valid
  end

  it 'is invalid when assessed, with no min or max value' do
    c1 = build(:weighted_criterium, assessment: Assessment.first, min_value: nil, max_value: nil)
    expect(c1).to_not be_valid
    c1.min_value = 1
    c1.max_value = 10
    expect(c1).to be_valid
  end

  it 'is invalid when the weighting is 0 or lower' do
    c1 = build(:weighted_criterium, assessment: Assessment.first, weighting: 0)
    expect(c1).to_not be_valid
    c1.weighting = -1
    expect(c1).to_not be_valid
    c1.weighting = 1
    expect(c1).to be_valid
  end

end