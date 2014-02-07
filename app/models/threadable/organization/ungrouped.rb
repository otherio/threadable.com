require_dependency 'threadable/organization'

class Threadable::Organization::Ungrouped

  include Let

  def initialize organization
    @organization = organization
  end
  attr_reader :organization
  delegate :threadable, :organization_record, to: :organization

  include Threadable::Conversation::Scopes

  def delivery_method
    organization_membership_record.ungrouped_delivery_method
  end

  def delivery_method= delivery_method
    organization_membership_record.update_attribute(:ungrouped_delivery_method, delivery_method)
  end

  Threadable::DELIVERY_METHODS.each do |delivery_method|
    define_method "gets_#{delivery_method}?" do
      self.delivery_method == delivery_method
    end
    define_method "gets_#{delivery_method}!" do
      self.delivery_method = delivery_method
    end
  end

  private

  def organization_membership_record
    organization.current_member.organization_membership_record
  end

  def conversations_scope
    ungrouped organization_record.conversations
  end

  def tasks_scope
    ungrouped organization_record.tasks
  end

  def ungrouped scope
    scope.
      joins('LEFT JOIN conversation_groups ON conversation_groups.conversation_id = conversations.id').
      where(conversation_groups:{conversation_id:nil})
  end


end
