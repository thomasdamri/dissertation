class AssessmentValidator < ActiveModel::Validator

  def validate(assessment)
    # Opening date must be before the closing date (can be the same day)
    if assessment.date_opened > assessment.date_closed
      assessment.errors[:date_opened] << "must be before the closing date"
    end
  end

end