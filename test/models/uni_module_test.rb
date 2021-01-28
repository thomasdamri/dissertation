# == Schema Information
#
# Table name: uni_modules
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  code       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  start_date :date
#  end_date   :date
#
require 'test_helper'

class UniModuleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
