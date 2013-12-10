class Covered::Conversations < Covered::Collection

  def all
    scope.map{ |conversation_record| conversation_for conversation_record }
  end

  def all_with_participants
    scope.includes(:participants).map{ |conversation| conversation_for conversation }
  end

  def find_by_id id
    conversation_for (scope.where(id: id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Covered::RecordNotFound, "unable to find Conversation with id #{slug.inspect}"
  end

  def find_by_slug slug
    conversation_for (scope.where(slug: slug).first or return)
  end

  def find_by_slug! slug
    find_by_slug(slug) or raise Covered::RecordNotFound, "unable to find Conversation with slug #{slug.inspect}"
  end

  def newest
    conversation_for (scope.first or return)
  end
  alias_method :latest, :newest

  def oldest
    conversation_for (scope.last or return)
  end


  def create attributes={}
    Create.call(self, attributes)
  end

  def create! attributes={}
    conversation = create(attributes)
    conversation.persisted? or raise Covered::RecordInvalid, "Conversation invalid: #{conversation.errors.full_messages.to_sentence}"
    conversation
  end

  private

  def scope
    ::Conversation.all
  end

  def conversation_for conversation_record
    Covered::Conversation.new(covered, conversation_record)
  end

end
