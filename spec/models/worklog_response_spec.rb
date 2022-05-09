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
# require 'rails_helper'

# RSpec.describe WorklogResponse, type: :model do
#   before(:each) do
#     staff = create :user, staff: true
#     mod = create :uni_module
#     create :staff_module, user: staff, uni_module: mod
#     t = create :team, uni_module: mod
#     author = create :user, staff: false, username: "zzz12pl", email: "l@gmail.com"
#     responder = create :user, staff: false, username: "zzz12pq", email: "p@gmail.com"
#     create :student_team, team: t, user: author
#     create :student_team, team: t, user: responder
#     create :worklog, author: author, uni_module: mod
#   end

#   it 'is valid with valid attributes' do
#     w = Worklog.first
#     responder = User.where(username: "zzz12pq").first
#     wr = build :worklog_response, worklog: w, user: responder, status: WorklogResponse.accept_status
#     expect(wr).to be_valid
#   end

#   it 'is invalid with blank attributes' do
#     wr = build :blank_worklog_response
#     expect(wr).to_not be_valid
#   end

#   it 'is invalid with a status outside the correct range' do
#     w = Worklog.first
#     responder = User.where(username: "zzz12pq").first
#     wr = build :worklog_response, worklog: w, user: responder, status: 74
#     expect(wr).to_not be_valid
#   end

#   it 'is invalid if the user has already responded to the associated worklog' do
#     w = Worklog.first
#     responder = User.where(username: "zzz12pq").first
#     wr = build :worklog_response, worklog: w, user: responder, status: WorklogResponse.accept_status
#     expect(wr).to be_valid
#     wr.save!

#     wr2 = build :worklog_response, worklog: w, user: responder, status: WorklogResponse.reject_status
#     expect(wr2).to_not be_valid
#   end

# end
