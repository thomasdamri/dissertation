# == Schema Information
#
# Table name: teams
#
#  id            :bigint           not null, primary key
#  uni_module_id :bigint
#  number        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Team < ApplicationRecord
end
