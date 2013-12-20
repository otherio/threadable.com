require_dependency 'covered/user'

class Covered::User::Update < MethodObject

  def call user, attributes

    if attributes[:password].blank?
      attributes.delete(:password)
      attributes.delete(:password_confirmation)
    end

    if user.user_record.update_attributes(attributes)
      user.track_update!
      true
    else
      false
    end
  end

end
