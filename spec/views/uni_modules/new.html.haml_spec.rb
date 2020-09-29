require 'rails_helper'

RSpec.describe "uni_modules/new", type: :view do
  before(:each) do
    assign(:uni_module, UniModule.new())
  end

  it "renders new uni_module form" do
    render

    assert_select "form[action=?][method=?]", uni_modules_path, "post" do
    end
  end
end
