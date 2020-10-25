class AssessmentResultValidator < ActiveModel::Validator

  def validate(ar)
    # Check value does not exceed min/max for ints and floats
    crit = ar.criterium
    response_type = crit.response_type
    if response_type.to_i == Criterium.int_type or response_type.to_i == Criterium.float_type
      min_val = crit.min_value
      max_val = crit.max_value
      # No point checking if min and max value dont exist
      if min_val.nil? and max_val.nil?
        return
      else
        if not min_val.nil?
          if ar.value < min_val
            ar.errors[:value] << "has exceeded the minimum value"
          end
        end

        if not max_val.nil?
          if ar.value > max_val
            ar.errors[:value] << "has exceeded the maximum value"
          end
        end

      end
    end
  end

end
