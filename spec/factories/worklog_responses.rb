# == Schema Information
#
# Table name: worklog_responses
#
#  id         :bigint           not null, primary key
#  worklog_id :bigint
#  user_id    :bigint
#  status     :integer
#  reason     :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :worklog_response do
    
  end
end
