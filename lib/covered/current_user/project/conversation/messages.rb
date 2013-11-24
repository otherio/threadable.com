class Covered::CurrentUser::Project::Conversation::Messages

  def initialize conversation
    @conversation = conversation
  end
  attr_reader :conversation
  delegate :covered, :project, to: :conversation


  def all
    scope.map{ |message| message_for message }
  end

  def build
    message_for scope.build
  end

  def newest
    message_for (scope.last or return)
  end
  alias_method :latest, :newest

  def oldest
    message_for (scope.first or return)
  end

  def count
    scope.count
  end

  def find_by_id id
    message_for (scope.where(id:id).first or return)
  end

  def find_by_id! id
    message = find_by_id(id)
    message or raise Covered::RecordNotFound, "unable to find conversation message with id: #{id}"
    message
  end


  def create attributes
    Create.call(conversation, attributes)
  end

  def create! attributes
    message = create(attributes)
    message.persisted? or raise Covered::RecordInvalid, "Message invalid: #{message.errors.full_messages.to_sentence}"
    message
  end


  def inspect
    %(#<#{self.class}>)
  end

  private

  def scope
    conversation.conversation_record.messages
  end

  def message_for message_record
    Covered::CurrentUser::Project::Conversation::Message.new(conversation, message_record)
  end

end

require 'covered/current_user/project/conversation/messages/create'
require 'covered/current_user/project/conversation/message'
