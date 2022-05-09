require 'rails_helper'

RSpec.describe StudentChat, type: :model do

  it 'validates message length properly' do 
    u = create :uni_module
    t = create :team, uni_module: u 
    u1 = create :user, username: 'test1', email: 'test1@gmail.com'
    st1 = create :student_team, user: u1, team: t
    chat = create :student_chat_one, student_team: st1
    invalid_chat = build :invalid_chat, student_team: st1
    expect(chat).to be_valid 
    expect(invalid_chat).to_not be_valid
  end

  describe "#get_user_id" do
    specify "It returns the correct id" do
      u = create :uni_module
      t = create :team, uni_module: u 
      u1 = create :user, username: 'test1', email: 'test1@gmail.com'
      st1 = create :student_team, user: u1, team: t
      chat = create :student_chat_one, student_team: st1
      expect(chat.get_user_id ).to eq u1.id
    end
  end

  describe '#whatAreNotes' do 
    it 'returns string correctly' do
      string = StudentChat.whatAreNotes()
      expect(string.first).to eq 'T'
      expect(string.last).to eq '.'
    end
  end

  describe '#whatToNote' do
    it 'returns string correctly' do
      string = StudentChat.whatToNote()
      expect(string.first).to eq 'T'
      expect(string.last).to eq '.'
    end
  end
end 



  