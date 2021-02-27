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
    end

    it 'sends an email to a student on the module who has a team grade + weighting for that assessment' do
      a = Assessment.first
      student = User.where(staff: false).first
      sw = create :student_weighting, user: student, weighting: 1.2, manual_set: false, assessment: a

      email = StudentMailer.score_email(student, a, TeamGrade.first, sw)
      expect(email.subject).to eq "Your Peer Assessment Grade"
      expect(email.body.encoded).to match sw.weighting.to_s
      expect(email.body.encoded).to match TeamGrade.first.grade.to_s
      expect(email.body.encoded).to match (sw.weighting.to_f * TeamGrade.first.grade.to_f).to_s
      # Non-manually set grade, no reason given
      expect(email.body.encoded).to_not match "Your peer-assessed weighting has been manually changed by a member of staff."
    end

    it 'sends an email to a student on the module, including the reason for a manually set grade' do
      a = Assessment.first
      student = User.where(staff: false).first
      sw = create :student_weighting, user: student, weighting: 1.2, manual_set: true, assessment: a, reason: "Blah blah blah"

      email = StudentMailer.score_email(student, a, TeamGrade.first, sw)
      expect(email.subject).to eq "Your Peer Assessment Grade"
      expect(email.body.encoded).to match sw.weighting.to_s
      expect(email.body.encoded).to match TeamGrade.first.grade.to_s
      expect(email.body.encoded).to match (sw.weighting.to_f * TeamGrade.first.grade.to_f).to_s
      # Non-manually set grade, no reason given
      expect(email.body.encoded).to match "Your peer-assessed weighting has been manually changed by a member of staff."
      expect(email.body.encoded).to match sw.reason
    end

  end

end