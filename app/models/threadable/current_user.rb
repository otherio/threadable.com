class Threadable::CurrentUser < Threadable::User

  def initialize threadable, user_id
    @threadable, @user_id = threadable, user_id
  end
  attr_reader :threadable, :user_id

  alias_method :id, :user_id

  def user_record
    @user_record ||= ::User.find(user_id)
  rescue ActiveRecord::RecordNotFound
    threadable.current_user_id = nil
    raise Threadable::CurrentUserNotFound, "unable to find user with id: #{user_id}"
  end

  delegate *%w{
    dismissed_welcome_modal?
  }, to: :user_record

  def dismissed_welcome_modal!
    user_record.update! dismissed_welcome_modal: true
    self
  end

end
