class SendConversationMessageWorker < ResqueWorker.new(:user, :message)

  queue :outgoing_mail

  def call
    #@user == user, @message == message

  end

end
