require 'rails_helper'

RSpec.describe "uni_modules/edit", type: :view do
  before(:each) do
    @uni_module = assign(:uni_module, UniModule.create!())
  end

  it "renders the edit uni_module form" do
    render

    assert_select "form[action=?][method=?]", uni_module_path(@uni_module), "post" do
    end
  end
end
