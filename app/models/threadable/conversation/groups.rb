require_dependency 'threadable/conversation'

class Threadable::Conversation::Groups < Threadable::Groups

  def initialize conversation
    @conversation = conversation
  end
  attr_reader :conversation
  delegate :threadable, to: :conversation

  def add *groups
    Threadable.transaction do
      group_records = groups.flatten.compact.map(&:group_record)

      add_group_records = group_records - groups_with_inactive.reload.to_a
      new_and_changed_group_records = group_records - scope.reload.to_a

      groups_with_inactive << add_group_records
      group_ids = groups.flatten.compact.map(&:id)
      conversation.conversation_record.conversation_groups.where(group_id: group_ids).update_all(active: true)
      conversation.cache_group_ids!

      new_and_changed_group_records.each do |group|
        conversation.events.create!(:conversation_added_group,
          user_id: threadable.current_user_id,
          group_id: group.id,
        )
      end
    end
    self
  end

  def add_unless_removed *groups
    groups = groups.flatten.compact
    existing_group_ids = conversation.conversation_record.conversation_groups.map(&:group_id)
    groups.reject!{ |group| existing_group_ids.include? group.group_id }
    Threadable.transaction do
      groups_with_inactive << groups.map(&:group_record)
      conversation.cache_group_ids!

      groups.each do |group|
        conversation.events.create!(:conversation_added_group,
          user_id: threadable.current_user_id,
          group_id: group.id,
        )
      end
    end
    self
  end

  def remove *groups
    group_ids = groups.flatten.compact.map(&:group_record).map(&:id)
    Threadable.transaction do
      conversation.conversation_record.conversation_groups.where(group_id: group_ids).update_all(active: false)
      conversation.cache_group_ids!

      group_ids.each do |group_id|
        conversation.events.create!(:conversation_removed_group,
          user_id: threadable.current_user_id,
          group_id: group_id,
        )
      end
    end
    self
  end

  private

  def scope
    conversation.conversation_record.groups.unload
  end

  def groups_with_inactive
    conversation.conversation_record.groups_with_inactive.unload
  end

end
