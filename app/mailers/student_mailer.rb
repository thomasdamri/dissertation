class StudentMailer < ApplicationMailer
  default from: "no-reply@sheffield.ac.uk"

  # Given a user and an assessment, email that user's score for that assessment to the user
  def score_email(user, assessment, team_grade, ind_weight)
    # Allow user + assessment to accessed from the email template
    @user = user
    @assessment = assessment
    @team_grade = team_grade
    @ind_weight = ind_weight

    @ind_grade = @team_grade.grade.to_f * @ind_weight.weighting

    mail to: user.email, subject: "Your Peer Assessment Grade"
  end

end