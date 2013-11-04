class UserCreator < MethodObject.new(:params)

  def call
    @user = Covered::User.new(@params)
    @user.save
    @user
  end


end
