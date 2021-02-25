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
    status { 0 }
    reason { "They are lying" }
  end

  factory :blank_worklog_response, class: 'WorklogResponse' do

  end
end
