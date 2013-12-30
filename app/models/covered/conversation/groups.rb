require_dependency 'covered/conversation'

class Covered::Conversation::Groups < Covered::Groups

  def initialize conversation
    @conversation = conversation
  end
  attr_reader :conversation
  delegate :covered, to: :conversation

  def add *groups
    Covered.transaction do
      group_records = groups.flatten.compact.map(&:group_record) - groups_association.to_a
      groups_association << group_records
      group_ids = groups.flatten.compact.map(&:group_record).map(&:id)
      conversation.conversation_record.conversation_groups.where(group_id: group_ids).update_all(active: true)
    end
    self
  end

  def add_unless_removed *groups
    group_records = groups.flatten.compact.map(&:group_record) - groups_association.to_a
    groups_association << group_records
    self
  end

  def remove *groups
    group_ids = groups.flatten.compact.map(&:group_record).map(&:id)
    conversation.conversation_record.conversation_groups.where(group_id: group_ids).update_all(active: false)
    self
  end

  private

  def scope
    groups_association.active
  end

  def groups_association
    conversation.conversation_record.groups
  end

end
