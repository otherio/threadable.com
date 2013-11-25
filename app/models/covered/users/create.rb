class Covered::Users::Create < MethodObject

  def call covered, attributes
    @covered, @attributes = covered, attributes.symbolize_keys
    @user_record = ::User.create(@attributes)
    return @user_record
  end

end
