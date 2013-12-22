class Covered::Users::Create < MethodObject

  def call covered, attributes
    attributes = attributes.dup

    confirm_email_address = !!attributes.delete(:confirm_email_address)
    email_address         = attributes.delete(:email_address)

    email_address = covered.email_addresses.build(
      address: email_address,
      primary: true,
      confirmed_at: confirm_email_address ? Time.now : nil,
    )

    attributes[:email_addresses] = [email_address.email_address_record]

    user = Covered::User.new(covered, ::User.create(attributes))
    user.track_update! if user.persisted?
    user
  end

end
