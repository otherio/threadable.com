require_dependency 'threadable/organization'
require_dependency 'threadable/organization/email_domain'

class Threadable::Organization::EmailDomains < Threadable::EmailDomains

  def initialize organization
    @organization = organization
    @threadable   = organization.threadable
  end
  attr_reader :organization

  def outgoing
    email_domain_for (scope.outgoing.first or return)
  end

  def add email_domain, outgoing=false
    require_settings_permission
    raise(Threadable::AuthorizationError, 'A paid account is required to change domain settings') unless organization.paid?

    Threadable.transaction do
      email_domain = email_domain_for organization.organization_record.email_domains.create(domain: email_domain)
      email_domain.outgoing! if outgoing
    end
    email_domain
  end

  def add! email_domain, outgoing=false
    email_domain = add(email_domain, outgoing)
    email_domain.persisted? or raise Threadable::RecordInvalid, "organization email domain invalid: #{email_domain.errors.full_messages.to_sentence}"
    email_domain
  end

  def remove email_domain
    require_settings_permission

    domain_object = organization.email_domains.find_by_domain(email_domain)
    domain_object.destroy if domain_object.present?
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization.id}>)
  end

  private

  def scope
    organization.organization_record.email_domains.unload
  end

  def email_domain_for email_domain_record
    Threadable::Organization::EmailDomain.new(organization, email_domain_record) if email_domain_record
  end

  def require_settings_permission
    organization.members.current_member.can?(:change_settings_for, organization) or raise Threadable::AuthorizationError, 'You do not have permission to change settings for this organization'
  end

end
