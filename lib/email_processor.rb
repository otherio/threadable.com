class EmailProcessor
  def self.process(email)
    project = Project.where(slug: email.to).first
    user = project.members.where(email: email.from).first

    # parse headers
    headers = Mail::Header.new(email.params[:headers])

    if headers['In-Reply-To']
      parent_message = Message.where(message_id_header: headers['In-Reply-To'].to_s).first
      conversation = parent_message.conversation
    end

    unless conversation
      # make a new conversation
    end

    message = conversation.messages.create(
      subject: email.subject,
      parent_message: parent_message,
      user: user,
      from: email.from,
      body: email.body
    )

    message.save
    message
  end
end
