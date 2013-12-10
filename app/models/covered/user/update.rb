require_dependency 'covered/user'

class Covered::User::Update < MethodObject

  def call user, attributes
    if user.user_record.update_attributes(attributes)
      user.track_update!
      true
    else
      false
    end
  end

end
