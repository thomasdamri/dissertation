require 'rails_helper'

RSpec.describe "assessments/index", type: :view do
  before(:each) do
    assign(:assessments, [
      Assessment.create!(),
      Assessment.create!()
    ])
  end

  it "renders a list of assessments" do
    render
  end
end
