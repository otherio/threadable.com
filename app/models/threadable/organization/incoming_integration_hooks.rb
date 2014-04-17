require_dependency 'threadable/organization'

class Threadable::Organization::IncomingIntegrationHooks < Threadable::IncomingIntegrationHooks

  def initialize organization
    @organization = organization
    @threadable = organization.threadable
  end
  attr_reader :organization

  private

  def scope
    organization.organization_record.incoming_integration_hooks
  end

end
