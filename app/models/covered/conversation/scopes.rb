require_dependency 'covered/conversation'

module Covered::Conversation::Scopes

  def muted_conversations
    conversations_for conversations_scope.muted_by(covered.current_user_id)
  end

  def not_muted_conversations
    conversations_for conversations_scope.not_muted_by(covered.current_user_id)
  end

  def done_tasks
    conversations_for tasks_scope.done # TODO: sort by done_at
  end

  def not_done_tasks
    conversations_for tasks_scope.not_done # TODO: sort by position
  end

  def done_doing_tasks
    conversations_for tasks_scope.doing_by(covered.current_user_id).done # TODO: sort by done_at
  end

  def not_done_doing_tasks
    conversations_for tasks_scope.doing_by(covered.current_user_id).not_done # TODO: sort by position
  end

  private

  def conversations_for conversation_records
    conversation_records.map do |conversation_record|
      Covered::Conversation.new(covered, conversation_record)
    end
  end

  # conversations_scope should either be an organization's or a group's conversations active record association scope
  def conversations_scope
    raise 'conversations_scope should be implimented in the object that includes Covered::Conversation::Scopes'
  end

  # tasks_scope should either be an organization's or a group's tasks active record association scope
  def tasks_scope
    raise 'tasks_scope should be implimented in the object that includes Covered::Conversation::Scopes'
  end

end
