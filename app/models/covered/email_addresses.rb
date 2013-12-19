class Covered::EmailAddresses < Covered::Collection

  def all
    email_addresses_for scope.reload.to_a
  end

  def find_by_addresses addresses
    email_address_records = scope.where(address: addresses).to_a
    email_address_records = addresses.map do |email_address|
      email_address_records.find do |email_address_record|
        email_address_record.address == email_address
      end
    end
    email_addresses_for email_address_records
  end

  def create attributes={}
    Create.call(self, attributes)
  end

  def create! attributes={}
    email_address = create(attributes)
    email_address.persisted? or raise Covered::RecordInvalid, "EmailAddress invalid: #{email_address.errors.full_messages.to_sentence}"
    email_address
  end

  private

  def scope
    ::EmailAddress.all
  end

  def email_address_for email_address_record
    Covered::EmailAddress.new(covered, email_address_record) if email_address_record
  end

  def email_addresses_for email_address_records
    email_address_records.map{ |email_address_record| email_address_for email_address_record }
  end

end
