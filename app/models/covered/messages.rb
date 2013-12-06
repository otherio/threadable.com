class Covered::Messages < Covered::Collection

  autoload :Create
  autoload :FindByChildHeader

  def all
    scope.reload.map{ |message_record| message_for message_record }
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
    message = find_by_id(id)
    message or raise Covered::RecordNotFound, "unable to find conversation message with id: #{id}"
    message
  end

  def find_by_message_id_header message_id_header
    message_for (scope.where(message_id_header: message_id_header).first or return)
  end

  def find_by_message_id_header! message_id_header
    message = find_by_message_id_header(message_id_header)
    message or raise Covered::RecordNotFound, "unable to find conversation message message id header: #{message_id_header}"
    message
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
    Covered::Message.new(covered, message_record)
  end

end
