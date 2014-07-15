require_dependency 'threadable/email_domain'

class Threadable::EmailDomains < Threadable::Collection

  def all
    email_domains_for scope.to_a
  end

  def find_by_id id
    email_domain_for (scope.where(id: id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Threadable::RecordNotFound, "unable to find email domain with id: #{id.inspect}"
  end

  def find_by_domain domain
    email_domain_for (scope.domain(domain).first or return)
  end

  def find_by_domain! domain
    find_by_domain(domain) or raise Threadable::RecordNotFound, "unable to find email domain: #{domain.inspect}"
  end

  def taken? domain
    email_domain = find_by_domain(domain) or return false
    return email_domain.present?
  end

  def new attributes={}
    Threadable::EmailDomain.new(threadable, ::EmailDomain.new(attributes))
  end
  alias_method :build, :new

  def create attributes={}
    email_domain_record = scope.create(attributes)
    Threadable::EmailDomain.new(threadable, email_domain_record)
  end

  def create! attributes={}
    email_domain = create(attributes)
    email_domain.persisted? or raise Threadable::RecordInvalid, "EmailDomain invalid: #{email_domain.errors.full_messages.to_sentence}"
    email_domain
  end

  def find_or_create_by_domain! domain
    find_by_domain(domain) || create!(domain: domain)
  end

  private

  def scope
    ::EmailDomain.all
  end

  def email_domain_for email_domain_record
    Threadable::EmailDomain.new(threadable, email_domain_record) if email_domain_record
  end

  def email_domains_for email_domain_records
    email_domain_records.map{ |email_domain_record| email_domain_for email_domain_record }
  end

end
