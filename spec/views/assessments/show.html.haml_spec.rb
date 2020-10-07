require 'rails_helper'

RSpec.describe "assessments/show", type: :view do
  before(:each) do
    @assessment = assign(:assessment, Assessment.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
