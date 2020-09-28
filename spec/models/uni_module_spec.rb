require 'rails_helper'

RSpec.describe UniModule, type: :model do
  it 'is valid with a name and code' do
    mod = build(:uni_module)
    expect(mod).to be_valid
  end

  it 'is invalid with a non unique name or code' do
    mod = build(:empty_uni_module)
    expect(mod).to_not be_valid
  end
end
