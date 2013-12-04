class Covered::User::Update < MethodObject

  def call user, attributes
    result = user.user_record.update_attributes(attributes)
    user.track_update! if result
    !!result
  end

end
