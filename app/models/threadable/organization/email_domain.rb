require_dependency 'threadable/organization'

class Threadable::Organization::EmailDomain < Threadable::EmailDomain

  def initialize organization, email_domain_record
    super(organization.threadable, email_domain_record)
    @organization = organization
  end
  attr_reader :organization

  def outgoing!
    # TODO: remember to check confirmed here when we have that.
    require_settings_permission
    require_paid
    return if email_domain_record.outgoing?
    Threadable.transaction do
      ::EmailDomain.where(organization_id: organization.id).update_all(outgoing: false)
      email_domain_record.update(outgoing: true)
      organization.organization_record.email_domains.reload
    end
    return true
  end

  def not_outgoing!
    # TODO: remember to check confirmed here when we have that.
    require_settings_permission
    require_paid
    return unless email_domain_record.outgoing?
    Threadable.transaction do
      email_domain_record.update(outgoing: false)
      organization.organization_record.email_domains.reload
    end
    return true
  end

  private

  def require_paid
    raise(Threadable::AuthorizationError, 'A paid account is required to change domain settings') unless organization.paid?
  end

  def require_settings_permission
    organization.members.current_member.can?(:change_settings_for, organization) or raise Threadable::AuthorizationError, 'You do not have permission to change settings for this organization'
  end

end
