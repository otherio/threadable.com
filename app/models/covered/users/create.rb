class Covered::Users::Create < MethodObject

  def call covered, attributes
    user = Covered::User.new(covered, ::User.create(attributes))
    user.update_mixpanel if user
    user
  end

end
