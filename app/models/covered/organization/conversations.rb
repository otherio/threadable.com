require_dependency 'covered/organization'

class Covered::Organization::Conversations < Covered::Conversations

  def initialize organization
    @organization = organization
    @covered = organization.covered
  end
  attr_reader :organization

  def build attributes={}
    conversation_for scope.build(attributes)
  end
  alias_method :new, :build

  def create attributes={}
    super attributes.merge(organization: organization)
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization.id.inspect}>)
  end

  private

  def scope
    organization.organization_record.conversations.unload
  end

end
