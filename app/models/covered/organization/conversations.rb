require_dependency 'covered/organization'

class Covered::Organization::Conversations < Covered::Conversations

  def initialize organization
    @organization = organization
    @covered = organization.covered
  end
  attr_reader :organization

  def muted
    return [] if covered.current_user_id.nil?
    conversations_for muted_scope
  end

  def not_muted
    return [] if covered.current_user_id.nil?
    conversations_for not_muted_scope
  end

  def muted_with_participants
    return [] if covered.current_user_id.nil?
    conversations_for muted_scope.includes(:participants)
  end

  def not_muted_with_participants
    return [] if covered.current_user_id.nil?
    conversations_for not_muted_scope.includes(:participants)
  end

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

  def muted_scope
    scope.muted_by(covered.current_user_id)
  end

  def not_muted_scope
    scope.not_muted_by(covered.current_user_id)
  end

end
