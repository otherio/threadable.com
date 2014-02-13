require_dependency 'threadable/user'

class Threadable::User::Update < MethodObject

  def call user, attributes

    attributes = attributes.to_hash.symbolize_keys
    attributes.delete(:admin)

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
