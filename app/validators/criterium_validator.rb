class CriteriumValidator < ActiveModel::Validator

  def validate(crit)
    # Check weighting is either nil, or positive
    unless crit.weighting.nil?
      if crit.weighting <= 0
        crit.errors[:weighting] << "must be greater than 0"
      end
    end
    # Check max_val is greater than or equal to min_val for ints and floats
    if crit.response_type.to_i == Criterium.int_type or crit.response_type.to_i == Criterium.float_type
      unless crit.max_value.nil? or crit.min_value.nil?
        if crit.max_value < crit.min_value
          crit.errors[:max_value] << "must be greater than the minimum value"
        end
      end
    end
    # Check booleans have labels
    if crit.response_type.to_i == Criterium.bool_type
      if crit.min_value.nil?
        crit.errors[:min_value] << "cannot be empty. Please enter a label"
      end

      if crit.max_value.nil?
        crit.errors[:max_value] << "cannot be empty. Please enter a label"
      end
    end
    # Check assessed criteria have min and max values
    if crit.assessed
      if crit.min_value.nil?
        crit.errors[:min_value] << "must not be empty if the criteria is assessed"
      end
      if crit.max_value.nil?
        crit.errors[:max_value] << "must not be empty if the criteria is assessed"
      end
    end
  end

end