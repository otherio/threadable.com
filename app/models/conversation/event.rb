class Conversation::Event < Event

  belongs_to :conversation

  def project_id
    super or self.project_id = conversation.project_id if conversation
  end

  def project
    super or self.project = conversation.project if conversation
  end

end
