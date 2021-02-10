# == Schema Information
#
# Table name: worklogs
#
#  id            :bigint           not null, primary key
#  author_id     :bigint
#  fill_date     :date
#  content       :text(65535)
#  override      :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  uni_module_id :bigint
#
FactoryBot.define do
  factory :worklog do
    fill_date { Date.today.monday? ? Date.today : Date.today.prev_occurring(:monday) }
    content { "I did some work this week." }
  end

  factory :blank_worklog, class: 'Worklog' do

  end

end
