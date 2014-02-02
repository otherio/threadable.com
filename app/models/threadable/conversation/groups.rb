require_dependency 'threadable/conversation'

class Threadable::Conversation::Groups < Threadable::Groups

  def initialize conversation
    @conversation = conversation
  end
  attr_reader :conversation
  delegate :threadable, to: :conversation

  def add *groups
    Threadable.transaction do
      group_records = groups.flatten.compact.map(&:group_record) - groups_association.reload.to_a
      groups_association << group_records
      group_ids = groups.flatten.compact.map(&:group_record).map(&:id)
      conversation.conversation_record.conversation_groups.where(group_id: group_ids).update_all(active: true)
      conversation.cache_group_ids!
    end
    self
  end

  def add_unless_removed *groups
    groups = groups.flatten.compact
    existing_group_ids = conversation.conversation_record.conversation_groups.map(&:group_id)
    groups.reject!{ |group| existing_group_ids.include? group.group_id }
    Threadable.transaction do
      groups_association << groups.map(&:group_record)
      conversation.cache_group_ids!
    end
    self
  end

  def remove *groups
    group_ids = groups.flatten.compact.map(&:group_record).map(&:id)
    Threadable.transaction do
      conversation.conversation_record.conversation_groups.where(group_id: group_ids).update_all(active: false)
      conversation.cache_group_ids!
    end
    self
  end

  private

  def scope
    groups_association.where(conversation_groups: {active: true})
  end

  def groups_association
    conversation.conversation_record.groups.unload
  end

end