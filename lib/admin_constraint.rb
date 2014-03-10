class AdminConstraint
  def matches?(request)
    request.session[:user_id] or return false
    user = User.where(id: request.session[:user_id]).first or return false
    user.admin?
  end
end
