require_dependency 'threadable/organization'

class Threadable::Organization::Messages < Threadable::Messages

  def initialize organization
    @organization = organization
    @threadable = organization.threadable
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
