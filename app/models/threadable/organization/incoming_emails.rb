require_dependency 'threadable/organization'

class Threadable::Organization::IncomingEmails < Threadable::IncomingEmails

  def initialize organization
    @organization = organization
    @threadable = organization.threadable
  end
  attr_reader :organization

  private

  def scope
    organization.organization_record.incoming_emails
  end

end
