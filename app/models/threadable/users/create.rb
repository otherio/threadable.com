class Threadable::Users::Create < MethodObject

  def call threadable, attributes
    attributes = attributes.dup

    confirm_email_address = !!attributes.delete(:confirm_email_address)
    email_address         = attributes.delete(:email_address)

    email_address = threadable.email_addresses.build(
      address: email_address,
      primary: true,
      confirmed_at: confirm_email_address ? Time.now : nil,
    )

    attributes[:email_addresses] = [email_address.email_address_record]

    user = Threadable::User.new(threadable, ::User.create(attributes))
    user.track_update! if user.persisted?
    user
  end

end
