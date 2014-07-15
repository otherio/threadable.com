class Threadable::EmailDomain < Threadable::Model

  self.model_name = ::EmailDomain.model_name

  def initialize threadable, email_domain_record
    @threadable, @email_domain_record = threadable, email_domain_record
  end
  attr_reader :threadable, :email_domain_record

  delegate *%w{
    id
    errors
    persisted?
    outgoing?
  }, to: :email_domain_record

  def domain
    email_domain_record.domain.try(:downcase)
  end

  def to_s
    domain.to_s
  end
  alias_method :to_str, :to_s

  def to_param
    domain
  end

  def organization
    @organization ||= threadable.organizations.find_by_id(organization_id) if organization_id
  end

  def == other
    id.nil? ? (self.class === other && other.id == id) : (other.to_s == self.to_s)
  end

  def inspect
    %(#<#{self.class} domain: #{domain.inspect}, outgoing: #{outgoing?.inspect}>)
  end

end
