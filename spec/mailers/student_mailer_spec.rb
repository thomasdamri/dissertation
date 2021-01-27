require "rails_helper"

RSpec.describe StudentMailer, type: :mailer do

  describe 'score_email' do
    before(:each) do
      mod = create :uni_module
      a = create :assessment, uni_module: mod
      t = create :team, uni_module: mod
      student = create :user, staff: false
      create :student_team, user: student, team: t
      create :team_grade, team: t, grade: 70, assessment: a
      create :student_weighting, user: student, weighting: 1.2, manual_set: true, assessment: a
    end

    it 'sends an email to a student on the module who has a team grade + weighting for that assessment' do
      email = StudentMailer.score_email(User.first, Assessment.first, TeamGrade.first, StudentWeighting.first)
      expect(email.subject).to eq "Your Peer Assessment Grade"
      expect(email.body.encoded).to match StudentWeighting.first.weighting.to_s
      expect(email.body.encoded).to match TeamGrade.first.grade.to_s
      expect(email.body.encoded).to match (StudentWeighting.first.weighting.to_f * TeamGrade.first.grade.to_f).to_s
    end

  end

end
