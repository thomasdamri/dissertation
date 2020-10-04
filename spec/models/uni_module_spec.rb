require 'rails_helper'

RSpec.describe UniModule, type: :model do
  it 'is valid with a name and code' do
    mod = build(:uni_module)
    expect(mod).to be_valid
  end

  it 'is invalid with empty attributes' do
    mod = build(:empty_uni_module)
    expect(mod).to_not be_valid
  end

  it 'is invalid with a non-unique name or code' do
    m1 = create(:uni_module)
    expect(m1).to be_valid

    m2 = build(:uni_module)
    expect(m2).to_not be_valid

    m2.name = "Something else"
    expect(m2).to_not be_valid

    m2.code = "ZZZ9999"
    expect(m2).to be_valid
  end

end
