class Covered::Project::Conversation::Participants

  def initialize conversation
    @conversation = conversation
  end
  attr_reader :conversation
  delegate :covered, to: :conversation

  def all
    scope.map{ |participant| participant_for participant }
  end

  def build
    participant_for scope.build
  end

  def inspect
    %(#<#{self.class}>)
  end

  private

  def scope
    conversation.conversation_record.participants
  end

  def participant_for user_record
    Covered::Project::Conversation::Participant.new(conversation, user_record)
  end

end
