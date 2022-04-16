class StudentMailer < ApplicationMailer
  default from: "TeamPlayerPlus Assessment System <no-reply@sheffield.ac.uk>"

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

  def reporter_response(user, reporter_response)
    @user = user
    @reporter_response = reporter_response
    mail to: user.email, subject: "Report Response"
  end

  def reportee_response(user, reportee_response)
    @user = user
    @reportee_response = reportee_response
    mail to: user.email, subject: "Report Details"
  end

end