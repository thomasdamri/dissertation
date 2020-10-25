class AssessmentValidator < ActiveModel::Validator

  def validate(assessment)
    # Checks dates have been included before checking validity. If dates are not included, other validations will fail
    if not assessment.date_opened.nil? and not assessment.date_closed.nil?
      # Opening date must be before the closing date (can be the same day)
      if assessment.date_opened > assessment.date_closed
        assessment.errors[:date_opened] << "must be before the closing date"
      end
    end
  end

end