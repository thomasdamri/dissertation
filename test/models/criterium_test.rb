# == Schema Information
#
# Table name: criteria
#
#  id            :bigint           not null, primary key
#  title         :string(255)
#  order         :integer
#  type          :string(255)
#  min_value     :float(24)
#  max_value     :float(24)
#  assessment_id :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'test_helper'

class CriteriumTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
