class Threadable::Messages < Threadable::Collection

  def all
    messages_for scope.to_a
  end

  def all_for_conversation_events user
    user_id = ::Message.sanitize(user.id)
    messages_for scope.
      eager_load(:creator, :attachments).
      joins("LEFT OUTER JOIN sent_emails ON messages.id = sent_emails.message_id and sent_emails.user_id = #{user_id}").
      to_a
  end

  def not_sent_to user
    messages_for scope.not_sent_to(user.id)
  end

  def count_for_date time
    time = time.midnight
    scope.where('messages.created_at BETWEEN ? and ?', time, time + 1.day).count
  end

  def latest
    message_for (scope.last or return)
  end
  alias_method :last, :latest

  def oldest
    message_for (scope.first or return)
  end
  alias_method :first, :oldest

  def find_by_id id
    message_for (scope.find(id) or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Threadable::RecordNotFound, "unable to find conversation message with id: #{id}"
  end

  def find_by_ids ids
    messages_for scope.find(ids)
  end

  def find_by_message_id_header message_id_header
    message_for (scope.where(message_id_header: message_id_header).first or return)
  end

  def find_by_message_id_header! message_id_header
    find_by_message_id_header(message_id_header) or
      raise Threadable::RecordNotFound, "unable to find conversation message message id header: #{message_id_header}"
  end

  def build attributes={}
    message_for scope.build(attributes)
  end

  def create attributes
    Create.call(self, attributes)
  end

  def create! attributes
    message = create(attributes)
    message.persisted? or raise Threadable::RecordInvalid, "Message invalid: #{message.errors.full_messages.to_sentence}"
    message
  end


  private

  def scope
    ::Message.all
  end

  def message_for message_record
    Threadable::Message.new(threadable, message_record) if message_record
  end

  def messages_for message_records
    message_records.map{|message_record| message_for message_record }
  end

end
