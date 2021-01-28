# == Schema Information
#
# Table name: worklogs
#
#  id         :bigint           not null, primary key
#  author_id  :bigint
#  fill_date  :date
#  content    :text(65535)
#  override   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :worklog do
    
  end
end
