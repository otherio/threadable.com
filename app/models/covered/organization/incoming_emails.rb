require_dependency 'covered/organization'

class Covered::Organization::IncomingEmails < Covered::IncomingEmails

  def initialize organization
    @organization = organization
    @covered = organization.covered
  end
  attr_reader :organization

  private

  def scope
    organization.organization_record.incoming_emails
  end

end
