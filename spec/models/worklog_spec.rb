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
require 'rails_helper'

RSpec.describe Worklog, type: :model do
  before(:each) do
    staff = create :user, staff: true
    mod = create :uni_module
    create :staff_module, user: staff, uni_module: mod
    t = create :team, uni_module: mod
    student = create :user, staff: false, username: "zzz12pl", email: "l@gmail.com"
    create :student_team, team: t, user: student
  end

  it 'is valid with valid attributes' do
    mod = UniModule.first
    student = User.where(staff: false).first
    w = build :worklog, author: student, uni_module: mod
    expect(w).to be_valid
  end

  it 'is invalid with blank attributes' do
    w = build(:blank_worklog)
    expect(w).to_not be_valid
  end

  it 'is invalid when content is > 280 characters' do
    mod = UniModule.first
    student = User.where(staff: false).first
    w = build :worklog, author: student, uni_module: mod, content: ("a" * 281)
    expect(w).to_not be_valid
    w.content = ("a" * 280)
    expect(w).to be_valid
  end

  it 'removes all responses on deletion' do
    mod = UniModule.first
    student = User.where(staff: false).first
    responder = create :user, staff: false, username: "zzz12mn", email: "1@gmail.com"
    w = create :worklog, uni_module: mod, author: student
    create :worklog_response, worklog: w, user: responder

    expect(WorklogResponse.count).to eq 1
    w.destroy
    expect(WorklogResponse.count).to eq 0
  end

  it 'is invalid if the user has already made work log for the same module and fill date' do
    mod = UniModule.first
    student = User.where(staff: false).first
    responder = create :user, staff: false, username: "zzz12mn", email: "1@gmail.com"
    w = create :worklog, uni_module: mod, author: student
    expect(w).to be_valid
    w2 = build :worklog, uni_module: mod, author: student
    expect(w2).to_not be_valid
  end

  describe '#is_overridden?' do
    it 'returns true when the override attribute is not nil' do
      mod = UniModule.first
      student = User.where(staff: false).first
      w = build(:worklog, uni_module: mod, author: student)

      # Override attribute is nil, should return false
      expect(w.is_overridden?).to eq false

      w.override = "Something else"
      expect(w.is_overridden?).to eq true
    end
  end

end
