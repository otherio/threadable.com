class Threadable::Conversations < Threadable::Collection

  def all
    conversations_for scope
  end

  def all_with_participants
    conversations_for scope.includes(:participants)
  end

  def all_for_message_list
    conversations_for scope.includes(:participants).includes(:messages)
  end

  def for_message_summary user, time
    scope.untrashed.with_last_message_at(time).not_followed_by(user.id).map {|conversation_record| conversation_for(conversation_record) }
  end

  def to_be_deleted
    scope.where('trashed_at < ?', Time.now.utc - 30.days).map {|conversation_record| conversation_for(conversation_record) }
  end

  def all_with_multiple_groups
    scope.
      joins(:conversation_groups).
      where(conversation_groups: {active: true}).
      group('conversations.id').
      having('count(conversation_groups.group_id) > 1').
      map {|conversation_record| conversation_for(conversation_record) }
  end

  def trashed
    conversations_for scope.trashed
  end

  def find_by_id id
    conversation_for (scope.where(id: id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Threadable::RecordNotFound, "unable to find Conversation with id #{id.inspect}"
  end

  def find_by_slug slug
    conversation_for (scope.where(slug: slug).first or return)
  end

  def find_by_slug! slug
    find_by_slug(slug) or raise Threadable::RecordNotFound, "unable to find Conversation with slug #{slug.inspect}"
  end

  def find_by_subject subject
    conversation_for (scope.order('conversations.created_at').where(subject: subject).first or return)
  end

  def find_by_subject! subject
    find_by_subject(subject) or raise Threadable::RecordNotFound, "unable to find Conversation with subject #{subject.inspect}"
  end

  def latest
    conversation_for (scope.first or return)
  end
  alias_method :last, :latest

  def oldest
    conversation_for (scope.last or return)
  end
  alias_method :first, :oldest

  def create attributes={}
    Create.call(self, attributes)
  end

  def create! attributes={}
    conversation = create(attributes)
    conversation.persisted? or raise Threadable::RecordInvalid, "Conversation invalid: #{conversation.errors.full_messages.to_sentence}"
    conversation
  end

  def empty_trash!
    trashed.each do |conversation|
      conversation.destroy!
    end
  end

  private

  def scope
    ::Conversation.order('conversations.updated_at DESC')
  end

  def conversation_for conversation_record
    Threadable::Conversation.new(threadable, conversation_record) if conversation_record
  end

  def conversations_for conversation_records
    conversation_records.map do |conversation_record|
      conversation_for conversation_record
    end
  end

end
