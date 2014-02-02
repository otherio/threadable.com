class Threadable::SignUp < MethodObject

  def call threadable, attributes
    threadable.users.create attributes
  end

end
