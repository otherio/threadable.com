class Threadable::SignUp < MethodObject

  def call threadable, attributes
    user = threadable.users.create attributes
    return user unless user.persisted?

    threadable.tracker.bind_tracking_id_to_user_id! user.id
    user.track_update!
    threadable.track_for_user(user.id, 'Sign up', attributes)
    return user
  end

end
