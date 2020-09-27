# == Schema Information
#
# Table name: assessment_results
#
#  id           :bigint           not null, primary key
#  author_id    :bigint
#  target_id    :bigint
#  criterium_id :bigint
#  value        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require 'test_helper'

class AssessmentResultTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
