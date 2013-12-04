class Covered::Users::Create < MethodObject

  def call covered, attributes
    user = Covered::User.new(covered, ::User.create(attributes))
    user.track_update! if user.persisted?
    user
  end

end
