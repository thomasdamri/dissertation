# == Schema Information
#
# Table name: student_teams
#
#  id      :bigint           not null, primary key
#  user_id :bigint
#  team_id :bigint
#
FactoryBot.define do

  factory :student_team_random, class: StudentTeam do

    
  end

  factory :student_team, class: StudentTeam do

  end
end
