class Covered::ProcessIncomingEmail < MethodObject

  extend ActiveSupport::Autoload

  autoload :CreateConversationMessage

  def call covered, incoming_email
    CreateConversationMessage.call(covered, incoming_email)

    # # if incoming_email.recipient_username.to_s == 'new'
    # #   covered.create_project_from_incoming_email(incoming_email)
    # #   incoming_email.processed!
    # #   return
    # # end


    # if incoming_email.sent_from_a_user? && incoming_email.sent_to_a_project?
    #   # project = covered.projects.find_by_email_address(incoming_email.recipient)
    #   covered.current_user_id = incoming_email.sender


    #   project.create_conversation_message_from_incoming_email incoming_email
    #   incoming_email.processed!
    # end


    # raise "unable to determine type of incoming email"
  end

end
