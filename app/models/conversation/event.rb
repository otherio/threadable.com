class Conversation::Event < Event

  belongs_to :conversation

  def organization_id
    super or self.organization_id = conversation.organization_id if conversation
  end

  def organization
    super or self.organization = conversation.organization if conversation
  end

end
