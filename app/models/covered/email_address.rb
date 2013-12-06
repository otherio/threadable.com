class Covered::EmailAddress < Covered::Model

  def initialize covered, email_address_record
    @covered, @email_address_record = covered, email_address_record
  end
  attr_reader :covered, :email_address_record

  delegate *%w{
    id
    address
    primary?
    errors
    persisted?
  }, to: :email_address_record

  def to_s
    address
  end

  def == other
    self.class === other && (id.nil? ? other.id == id : other.address == address)
  end

  def inspect
    %(#<#{self.class} address: #{address.inspect}, primary: #{primary?.inspect}>)
  end

end
