class Covered::CurrentUser < Covered::User

  def initialize covered, user_id
    @covered, @user_id = covered, user_id
  end
  attr_reader :covered, :user_id

  alias_method :id, :user_id

  def user_record
    @user_record ||= ::User.find(user_id)
  rescue ActiveRecord::RecordNotFound
    covered.current_user_id = nil
    raise Covered::AuthenticationError, "unable to find user with id: #{user_id}"
  end

end
