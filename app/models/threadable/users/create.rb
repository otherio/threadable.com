class Threadable::Users::Create < MethodObject

  def call threadable, attributes
    attributes = attributes.dup

    confirm_email_address = !!attributes.delete(:confirm_email_address)
    email_address         = attributes.delete(:email_address)

    email_address_record = threadable.email_addresses.find_by_address(email_address).try(:email_address_record)

    if email_address_record && email_address_record.user_id.present?
      raise "email address already in use"
    end

    email_address_record = threadable.email_addresses.build(
      address: email_address,
      primary: true,
      confirmed_at: confirm_email_address ? Time.now : nil,
    ).email_address_record

    attributes[:email_addresses] = [email_address_record]

    user = Threadable::User.new(threadable, ::User.create(attributes))
    user.track_update! if user.persisted?
    user
  end

end
