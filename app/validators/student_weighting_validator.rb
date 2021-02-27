class StudentWeightingValidator < ActiveModel::Validator
  def validate(record)
    if record.manual_set
      if record.reason.nil?
        record.errors[:reason] << "cannot be empty when manually setting a grade"
      end
    end
  end
end