require_dependency 'threadable/email_address'

class Threadable::EmailAddresses < Threadable::Collection

  def all
    email_addresses_for scope.to_a
  end

  def confirmed
    email_addresses_for scope.confirmed.to_a
  end

  def unconfirmed
    email_addresses_for scope.unconfirmed.to_a
  end

  def find_by_id id
    email_address_for (scope.where(id: id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Threadable::RecordNotFound, "unable to find email address with id: #{id.inspect}"
  end

  def find_by_address address
    email_address_for (scope.where(address: address).first or return)
  end

  def find_by_address! address
    find_by_address(address) or raise Threadable::RecordNotFound, "unable to find email address: #{address.inspect}"
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

  def taken? address
    email_address = find_by_address(address) or return false
    return email_address.user_id.present?
  end

  def new attributes={}
    Threadable::EmailAddress.new(threadable, ::EmailAddress.new(attributes))
  end
  alias_method :build, :new

  def create attributes={}
    Create.call(self, attributes)
  end

  def create! attributes={}
    email_address = create(attributes)
    email_address.persisted? or raise Threadable::RecordInvalid, "EmailAddress invalid: #{email_address.errors.full_messages.to_sentence}"
    email_address
  end

  def find_or_create_by_address! address
    find_by_address(address) || create!(address: address)
  end

  private

  def scope
    ::EmailAddress.all
  end

  def email_address_for email_address_record
    Threadable::EmailAddress.new(threadable, email_address_record) if email_address_record
  end

  def email_addresses_for email_address_records
    email_address_records.map{ |email_address_record| email_address_for email_address_record }
  end

end
