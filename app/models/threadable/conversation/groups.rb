require_dependency 'threadable/conversation'

class Threadable::Conversation::Groups < Threadable::Groups

  def initialize conversation
    @conversation = conversation
  end
  attr_reader :conversation
  delegate :threadable, to: :conversation
  delegate :conversation_record, to: :conversation

  def count
    conversation_record.groups_count
  end

  def add *groups
    groups = groups.flatten.compact
    group_ids = groups.map(&:id)
    Threadable.transaction do
      conversation_group_records = conversation_group_records_for(groups)

      groups.each do |group|
        conversation_group_record = conversation_group_record_for(group, conversation_group_records)
        conversation_group_record.active = true
        if conversation_group_record.new_record? || conversation_group_record.changed?
          conversation.events.create!(:conversation_added_group,
            user_id: threadable.current_user_id,
            group_id: conversation_group_record.group_id,
          )
        end
        conversation_group_record.save!
      end

      conversation.update_group_caches! conversation_group_records.select(&:active?).map(&:group_id)
    end
    self
  end

  def add_unless_removed *groups
    groups = groups.flatten.compact
    Threadable.transaction do
      conversation_group_records = conversation_group_records_for(groups)
      conversation_group_records.select(&:new_record?).each do |conversation_group_record|
        conversation_group_record.save!
        conversation.events.create!(:conversation_added_group,
          user_id: threadable.current_user_id,
          group_id: conversation_group_record.group_id,
        )
      end
      conversation.update_group_caches! conversation_group_records.select(&:active?).map(&:group_id)
    end
    self
  end

  def remove *groups
    groups = groups.flatten.compact
    group_ids = groups.map(&:id)
    return if
      group_ids.length == 1 &&
      conversation.groups.count == 1 &&
      groups.first == conversation.organization.groups.primary

    Threadable.transaction do
      conversation_record.conversation_groups.where(group_id: group_ids).update_all(active: false)

      group_ids.each do |group_id|
        conversation.events.create!(:conversation_removed_group,
          user_id: threadable.current_user_id,
          group_id: group_id,
        )
      end

      conversation.ensure_group_membership!
      conversation.update_group_caches!
    end
    self
  end

  private

  def scope
    conversation_record.groups.unload
  end

  def groups_with_inactive
    conversation_record.groups_with_inactive.unload
  end

  def conversation_group_records_for groups
    conversation_group_records = conversation_record.conversation_groups.to_a
    groups.map do |group|
      next if conversation_group_record_for(group, conversation_group_records)
      conversation_group_records << conversation_record.conversation_groups.new(group_id: group.id)
    end
    conversation_group_records
  end

  def conversation_group_record_for group, conversation_group_records
    conversation_group_records.find do |conversation_group_record|
      conversation_group_record.group_id == group.id
    end
  end

end
