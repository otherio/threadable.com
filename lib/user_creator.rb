class UserCreator < MethodObject.new(:params)

  def call
    @user = User.new(@params)
    @user.save
    @user
  end


end
