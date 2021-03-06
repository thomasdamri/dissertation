# == Schema Information
#
# Table name: staff_modules
#
#  id            :bigint           not null, primary key
#  user_id       :bigint
#  uni_module_id :bigint
#
class StaffModule < ApplicationRecord

  belongs_to :user, optional: true
  belongs_to :uni_module, optional: true

  # A staff member may only be assigned to a module once
  validates :user, uniqueness: {scope: :uni_module}

end
