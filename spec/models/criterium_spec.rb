# == Schema Information
#
# Table name: criteria
#
#  id            :bigint           not null, primary key
#  title         :string(255)
#  response_type :integer
#  min_value     :string(255)
#  max_value     :string(255)
#  assessment_id :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assessed      :boolean
#  weighting     :integer
#  single        :boolean
#
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

  it 'is invalid with a title that is too long' do
    a = Assessment.first
    # Create a non-assessed string type criteria
    c1 = build(:criterium, assessment: a)
    c1.title = "a" * Criterium.max_title_length
    expect(c1).to be_valid

    c1.title = "a" * (Criterium.max_title_length + 1)
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

  it 'is invalid when a boolean criterium has a missing label' do
    c1 = build(:criterium, assessment: Assessment.first, min_value: nil, max_value: nil, response_type: Criterium.bool_type)
    expect(c1).to_not be_valid
    c1.min_value = "Yes"
    expect(c1).to_not be_valid
    c1.max_value = "No"
    expect(c1).to be_valid
  end

  it 'is invalid if the response_type is outside the allowed range' do
    c1 = build(:criterium, assessment: Assessment.first, response_type: 550)
    expect(c1).to_not be_valid
    c1.response_type = Criterium.string_type
    expect(c1).to be_valid
  end

  describe "#type_dict" do
    specify "It returns the correct value" do
      expect(Criterium.type_dict["Text"]).to eq 0
    end
  end

  describe "#subtitle" do
    specify "it returns nil for string or bool responses" do
      c1 = build :criterium, response_type: Criterium.string_type
      c2 = build :criterium, response_type: Criterium.bool_type

      expect(c1.subtitle).to eq nil
      expect(c2.subtitle).to eq nil
    end

    specify "It returns the min, max, or both values for integer and float values" do
      c1 = build :criterium, response_type: Criterium.int_type
      expect(c1.subtitle).to eq "Enter a whole number"

      c1.response_type = Criterium.float_type
      expect(c1.subtitle).to eq "Enter a number"

      c1.min_value = 1
      expect(c1.subtitle).to eq "Enter a number which is 1 or more"

      c1.min_value = nil
      c1.max_value = 10.1
      expect(c1.subtitle).to eq "Enter a number which is 10.1 or less"

      c1.min_value = 1.2
      #expect(c1.subtitle).to eq "Enter a number between 1.2 and 10.1, where 1.2 is worst and 10.1 is best"
      expect(c1.subtitle).to eq "Enter a number between 1.2 and 10.1"
    end
  end

end
