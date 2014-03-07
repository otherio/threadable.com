class Threadable::Users::Create < MethodObject

  def call threadable, attributes
    attributes = attributes.dup
    confirm_email_address = !!attributes.delete(:confirm_email_address)
    user = Threadable::User.new(threadable, ::User.create(attributes))
    if user.persisted?
      user.email_addresses.find_by_address!(attributes[:email_address]).confirm! if confirm_email_address
      user.track_update!
    end
    user
  end

end
