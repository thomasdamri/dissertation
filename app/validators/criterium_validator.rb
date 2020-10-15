class CriteriumValidator < ActiveModel::Validator

  def validate(criterium)
    # All data types apart from string have a max/min value
    # Boolean min/max is set by the server
    resp_type_i = criterium.response_type.to_i
    if resp_type_i != Criterium.string_type.to_i and resp_type_i != Criterium.bool_type.to_i
      if criterium.min_value.nil?
        criterium.errors[:min_value] << "must be given for this field type"
      end

      if criterium.max_value.nil?
        criterium.errors[:max_value] << "must be given for this field type"
      end
    end
  end

end