require_dependency 'threadable/organization'

class Threadable::Organization::EmailDomain < Threadable::EmailDomain

  def initialize organization, email_domain_record
    super(organization.threadable, email_domain_record)
    @organization = organization
  end
  attr_reader :organization

  def outgoing!
    # TODO: remember to check confirmed here when we have that.
    Threadable.transaction do
      ::EmailDomain.where(organization_id: organization.id).update_all(outgoing: false)
      email_domain_record.update(outgoing: true)
    end
    organization.organization_record.email_domains.reload
    return true
  end

end
