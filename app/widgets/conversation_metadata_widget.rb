class ConversationMetadataWidget < Widgets::Base

  def init conversation
    locals[:conversation] = conversation
  end

end
