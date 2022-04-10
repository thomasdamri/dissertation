# == Schema Information
#
# Table name: assessment_results
#
#  id           :bigint           not null, primary key
#  author_id    :bigint
#  target_id    :bigint
#  criteria_id :bigint
#  value        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require 'rails_helper'

RSpec.describe AssessmentResult, type: :model do

  it 'is valid with an author and, optionally a target' do
    author = create :user, staff: false
    target = create :user, staff: false, username: "zzz12ed", email: "a@gmail.com"
    u = create :uni_module
    a = create :assessment, uni_module: u
    c = create :criteria, assessment: a
    ar = build :assessment_result_string, criteria: c, author: author
    expect(ar).to be_valid
    ar.target = target
    expect(ar).to be_valid
  end

  it 'is invalid with blank attributes' do
    ar = build :assessment_result_empty
    expect(ar).to_not be_valid
  end

  it 'is invalid with a value that is too large' do
    val1 = "a" * AssessmentResult.max_value_length
    val2 = "a" * (AssessmentResult.max_value_length + 1)

    author = create :user, staff: false
    target = create :user, staff: false, username: "zzz12ed", email: "a@gmail.com"
    u = create :uni_module
    a = create :assessment, uni_module: u
    c = create :criteria, assessment: a
    ar = build :assessment_result_string, criteria: c, author: author, value: val1
    expect(ar).to be_valid
    ar.value = val2
    expect(ar).to_not be_valid
  end

  it 'is only valid when responding to an int/float criteria if it is within the min + max value' do
    author = create :user, staff: false
    target = create :user, staff: false, username: "zzz12ed", email: "a@gmail.com"
    u = create :uni_module
    a = create :assessment, uni_module: u
    c = create :weighted_criteria, assessment: a
    ar = build :assessment_result_string, criteria: c, author: author, value: c.min_value.to_s
    expect(ar).to be_valid
    ar.value = (c.min_value.to_i - 1).to_s
    expect(ar).to_not be_valid
    ar.value = c.max_value.to_s
    expect(ar).to be_valid
    ar.value = (c.max_value.to_i + 1).to_s
    expect(ar).to_not be_valid
  end

end
