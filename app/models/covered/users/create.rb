class Covered::Users::Create < MethodObject

  def call covered, attributes
    Covered::User.new(covered, ::User.create(attributes))
  end

end
