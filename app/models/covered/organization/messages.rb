require_dependency 'covered/organization'

class Covered::Organization::Messages < Covered::Messages

  def initialize organization
    @organization = organization
    @covered = organization.covered
  end
  attr_reader :organization

  def find_by_child_message_header header
    message_for (FindByChildHeader.call(organization.id, header) or return)
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization.id.inspect}>)
  end

  private

  def scope
    organization.organization_record.messages
  end

end
