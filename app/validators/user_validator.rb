class UserValidator < ActiveModel::Validator
  def validate(user)
    # Check email address is valid
    unless user.email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      user.errors[:email] << 'is invalid'
      return
    end

    # Check the user exists on the university server
    # get_info_from_ldap always returns nil in test mode
    if !Rails.env.test?
      if user.get_info_from_ldap.nil?
        #user.errors[:email] << " does not belong to the university or does not exist"
      end
    end

    # Check display name does not exceed the character limit (if it exists)
    unless user.display_name.nil?
      if user.display_name.length > User.max_display_name_length
        user.errors[:display_name] << " is too long (exceeds maximum character limit of 250)"
      end
    end

  end
end