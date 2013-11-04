Covered::Operations.define :generate_email do

  option :type,    required: true
  option :options, default: {}

  def call
    case type.to_sym
    when :conversation_message
      ConversationMailer.new(covered).generate(:conversation_message, options)
    when :join_notice
      ProjectMembershipMailer.new(covered).generate(:join_notice, options)
    when :unsubscribe_notice
      ProjectMembershipMailer.new(covered).generate(:unsubscribe_notice, options)
    when :sign_up_confirmation
      UserMailer.new(covered).generate(:sign_up_confirmation, options)
    when :reset_password
      UserMailer.new(covered).generate(:reset_password, options)
    else
      raise "unknown email type #{type}"
    end
  end

end
