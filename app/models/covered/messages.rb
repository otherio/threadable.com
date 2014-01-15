class Covered::Messages < Covered::Collection

  def all
    messages_for scope.to_a
  end

  def all_with_creator_and_attachments
    messages_for scope.includes(:creator, :attachments).to_a
  end

  def latest
    message_for (scope.last or return)
  end

  def oldest
    message_for (scope.first or return)
  end

  def find_by_id id
    message_for (scope.find(id) or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Covered::RecordNotFound, "unable to find conversation message with id: #{id}"
  end

  def find_by_ids ids
    messages_for scope.find(ids)
  end

  def find_by_message_id_header message_id_header
    message_for (scope.where(message_id_header: message_id_header).first or return)
  end

  def find_by_message_id_header! message_id_header
    find_by_message_id_header(message_id_header) or
      raise Covered::RecordNotFound, "unable to find conversation message message id header: #{message_id_header}"
  end

  def build attributes={}
    message_for scope.build(attributes)
  end

  def create attributes
    Create.call(self, attributes)
  end

  def create! attributes
    message = create(attributes)
    message.persisted? or raise Covered::RecordInvalid, "Message invalid: #{message.errors.full_messages.to_sentence}"
    message
  end


  private

  def scope
    ::Message.all
  end

  def message_for message_record
    Covered::Message.new(covered, message_record) if message_record
  end

  def messages_for message_records
    message_records.map{|message_record| message_for message_record }
  end

end
