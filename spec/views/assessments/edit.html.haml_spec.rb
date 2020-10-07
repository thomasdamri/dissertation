require 'rails_helper'

RSpec.describe "assessments/edit", type: :view do
  before(:each) do
    @assessment = assign(:assessment, Assessment.create!())
  end

  it "renders the edit assessment form" do
    render

    assert_select "form[action=?][method=?]", assessment_path(@assessment), "post" do
    end
  end
end
