class EmailProcessor
  def self.process(email)
    project = Project.where(slug: email.to).first
    user = project.members.where(email: email.from).first

    # parse headers
    headers = Mail::Header.new(email.params[:headers])

    if headers['In-Reply-To']
      referenced_message = headers['In-Reply-To'].to_s
    elsif headers['References']
      referenced_message = headers['References'].to_s.split(' ').last
    end

    if referenced_message
      parent_message = Message.all(
        :joins => {
          :conversation => :project
        },
        :conditions => {
          :projects => { :id => project.id },
          :messages => { :message_id_header => referenced_message }
        }
      ).first
    end

    if parent_message
      conversation = parent_message.conversation
    else
      conversation = project.conversations.create(
        subject: email.subject,
        creator: user
      )
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
