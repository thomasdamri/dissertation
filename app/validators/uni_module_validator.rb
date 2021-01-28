class UniModuleValidator < ActiveModel::Validator
  def validate(mod)
    # Check start date is before end date
    unless mod.start_date.nil? or mod.end_date.nil?
      if mod.start_date > mod.end_date
        mod.errors[:end_date] << "cannot be before the start date"
      end
    end
  end
end