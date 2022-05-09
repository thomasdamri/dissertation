require 'rails_helper'

RSpec.describe StudentChat, type: :model do

  it 'validates report length' do 
    u = create :uni_module
    t = create :team, uni_module: u 
    u1 = create :user, username: 'test1', email: 'test1@gmail.com'
    st1 = create :student_team, user: u1, team: t
    report_valid = create :student_report_type_0, student_team: st1
    report_object = create :report_object, report_object_id: st1.id, student_report: report_valid
    expect(report_valid).to be_valid
    report_invalid = build :empty_report, student_team: st1
    expect(report_invalid).to_not be_valid
    expect(report_valid).to be_valid
  end


  it 'user object report' do
    u = create :uni_module
    t = create :team, uni_module: u 
    u1 = create :user, username: 'test1', email: 'test1@gmail.com'
    st1 = create :student_team, user: u1, team: t
    report_valid = create :student_report_type_0, student_team: st1
    expect(report_valid.reporting_int_to_string).to eq ("User")
  end

  it 'grade object report' do
    u = create :uni_module
    t = create :team, uni_module: u 
    u1 = create :user, username: 'test1', email: 'test1@gmail.com'
    st1 = create :student_team, user: u1, team: t
    report_valid = create :student_report_type_1, student_team: st1
    expect(report_valid.reporting_int_to_string).to eq ("Grade")
  end

  it 'task object report' do
    u = create :uni_module
    t = create :team, uni_module: u 
    u1 = create :user, username: 'test1', email: 'test1@gmail.com'
    st1 = create :student_team, user: u1, team: t
    report_valid = create :student_report_type_2, student_team: st1
    expect(report_valid.reporting_int_to_string).to eq ("Task")
  end

end



  