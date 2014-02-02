require_dependency 'threadable/conversation'

module Threadable::Conversation::Scopes

  PAGE_SIZE = 20

  def muted_conversations page
    conversations_for conversations_scope_with_includes.
      muted_by(threadable.current_user_id).
      limit(PAGE_SIZE).
      offset(PAGE_SIZE * page).uniq
  end

  def not_muted_conversations page
    conversations_for conversations_scope_with_includes.
      not_muted_by(threadable.current_user_id).
      limit(PAGE_SIZE).
      offset(PAGE_SIZE * page).uniq
  end

  def done_tasks page
    conversations_for tasks_scope_with_includes.
      done.
      order(done_at: :asc).
      limit(PAGE_SIZE).
      offset(PAGE_SIZE * page).uniq
  end

  def not_done_tasks page
    conversations_for tasks_scope_with_includes.
      not_done.
      order(position: :asc).
      limit(PAGE_SIZE).
      offset(PAGE_SIZE * page).uniq
  end

  def done_doing_tasks page
    conversations_for tasks_scope_with_includes.
      doing_by(threadable.current_user_id).
      done.
      order(done_at: :asc).
      limit(PAGE_SIZE).
      offset(PAGE_SIZE * page).uniq
  end

  def not_done_doing_tasks page
    conversations_for tasks_scope_with_includes.
      doing_by(threadable.current_user_id).
      not_done.
      order(position: :asc).
      limit(PAGE_SIZE).
      offset(PAGE_SIZE * page).uniq
  end

  private

  def conversations_for conversation_records
    conversation_records.map do |conversation_record|
      Threadable::Conversation.new(threadable, conversation_record)
    end
  end

  # conversations_scope should either be an organization's or a group's conversations active record association scope
  def conversations_scope
    raise 'conversations_scope should be implimented in the object that includes Threadable::Conversation::Scopes'
  end

  # tasks_scope should either be an organization's or a group's tasks active record association scope
  def tasks_scope
    raise 'tasks_scope should be implimented in the object that includes Threadable::Conversation::Scopes'
  end

  def conversations_scope_with_includes
    conversations_scope.includes(:creator)
  end

  def tasks_scope_with_includes
    tasks_scope.includes(:creator)
  end

end
