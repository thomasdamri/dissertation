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
FactoryBot.define do
  factory :team, class: 'Team' do
    team_number {1}
  end

  factory :blank_team, class: 'Team' do
  end

end
