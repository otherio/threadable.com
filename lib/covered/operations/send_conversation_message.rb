Covered::Operations.define :send_conversation_message do

  option :message_id, required: true
  option :email_sender, default: false

  let(:message){ Message.find message_id }
  let(:project){ message.conversation.project }
  let(:memberships){ project.memberships.that_get_email.includes(:user) }

  def call
    if !email_sender
      memberships.reject! do |membership|
        membership.user == message.user
      end
    end

    memberships.each do |membership|
      covered.send_email(:conversation_message, message_id: message.id, recipient_id: membership.user.id)
    end
  end

end
