require 'rails_helper'

RSpec.describe "uni_modules/show", type: :view do
  before(:each) do
    @uni_module = assign(:uni_module, UniModule.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
