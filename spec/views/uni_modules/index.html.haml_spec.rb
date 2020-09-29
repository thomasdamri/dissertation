require 'rails_helper'

RSpec.describe "uni_modules/index", type: :view do
  before(:each) do
    assign(:uni_modules, [
      UniModule.create!(),
      UniModule.create!()
    ])
  end

  it "renders a list of uni_modules" do
    render
  end
end
