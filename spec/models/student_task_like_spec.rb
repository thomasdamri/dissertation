require 'rails_helper'

RSpec.describe StudentChat, type: :model do

  it 'validates message length properly' do 
    u = create :uni_module
    t = create :team, uni_module: u 
    u1 = create :user, username: 'test1', email: 'test1@gmail.com'
    st1 = create :student_team, user: u1, team: t
    st1task = create :student_task_two, student_team: st1 
    like = create :like, user: u1, student_task: st1task
    expect(like).to be_valid
  end
end 



  