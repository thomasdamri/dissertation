require 'rails_helper'

RSpec.describe Assessment, type: :model do

  it 'is valid with valid attributes' do
    u = create :uni_module
    a = build :assessment
    a.uni_module = u
    expect(a).to be_valid
  end

  it 'is invalid with blank attributes' do
    a = build :blank_assessment
    expect(a).to_not be_valid
  end

  it 'is invalid with a non-unique name for its module' do
    u = create :uni_module
    a = create :assessment, uni_module: u
    a2 = build :assessment, uni_module: u

    expect(a).to be_valid
    expect(a2).to_not be_valid

    a2.name = "Something different"

    expect(a).to be_valid
    expect(a2).to be_valid
  end

  it 'is invalid with a close date before its opening date' do
    u = create :uni_module
    a = build :assessment
    a.uni_module = u
    a.date_closed = Date.new 2020, 9, 12
    expect(a).to_not be_valid
  end

  it 'deletes all dependent criteria on deletion' do
    u = create :uni_module
    a = create :assessment, uni_module: u

    c1 = create :criterium, assessment: a
    c2 = create :criterium, assessment: a, title: 'Something else', order: 2

    expect(Criterium.count).to eq(2)

    a.destroy

    expect(Criterium.count).to eq(0)

  end

end