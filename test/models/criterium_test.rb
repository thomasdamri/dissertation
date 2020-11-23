# == Schema Information
#
# Table name: criteria
#
#  id            :bigint           not null, primary key
#  title         :string(255)
#  response_type :integer
#  min_value     :string(255)
#  max_value     :string(255)
#  assessment_id :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assessed      :boolean
#  weighting     :integer
#  single        :boolean
#
require 'test_helper'

class CriteriumTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
