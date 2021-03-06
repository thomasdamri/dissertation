# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  email              :string(255)      default(""), not null
#  sign_in_count      :integer          default(0), not null
#  current_sign_in_at :datetime
#  last_sign_in_at    :datetime
#  current_sign_in_ip :string(255)
#  last_sign_in_ip    :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  username           :string(255)
#  uid                :string(255)
#  mail               :string(255)
#  ou                 :string(255)
#  dn                 :string(255)
#  sn                 :string(255)
#  givenname          :string(255)
#  display_name       :string(255)
#  reg_no             :integer
#  staff              :boolean
#  admin              :boolean
#
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
