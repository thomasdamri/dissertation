class AssessmentResultValidator < ActiveModel::Validator

  def validate(ar)
    # Check a criterium exists before doing other checks
    crit = ar.criterium
    if crit.nil?
      # Don't bother adding an error, the model validations will already do that
      return
    end
    # Check value does not exceed min/max for ints and floats
    response_type = crit.response_type
    if response_type.to_i == Criterium.int_type or response_type.to_i == Criterium.float_type
      min_val = crit.min_value.to_f
      max_val = crit.max_value.to_f
      val = ar.value.to_f
      # No point checking if min and max value dont exist
      if min_val.nil? and max_val.nil?
        return
      else
        unless min_val.nil?
          if val < min_val
            ar.errors[:value] << "has exceeded the minimum value"
          end
        end

        unless max_val.nil?
          if val > max_val
            ar.errors[:value] << "has exceeded the maximum value"
          end
        end

      end
    end
  end

end
