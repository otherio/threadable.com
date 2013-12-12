class Covered::SignUp < MethodObject

  def call covered, attributes
    covered.users.create attributes
  end

end
