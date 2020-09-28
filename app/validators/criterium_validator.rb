class CriteriumValidator < ActiveModel::Validator

  def validate(criterium)
    # All data types apart from string have a max/min value
    if criterium.type != Criterium.string_type
      if criterium.min_value.nil?
        criterium.errors[:min_value] << "must be given for this field type"
      end

      if criterium.max_value.nil?
        criterium.errors[:max_value] << "must be given for this field type"
      end
    end
  end

end