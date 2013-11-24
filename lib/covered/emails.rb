class Covered::Emails

  def initialize covered
    @covered = covered
  end
  attr_reader :covered

  def send_email type, *args
    generate(type, *args).deliver!
  end

  def send_email_async type, *args
    type?(type)
    SendEmailWorker.perform_async(covered.env, type, *args)
  end

  def generate type, *args
    type?(type)
    types[type.to_sym].new(covered).generate(type.to_sym, *args)
  end

  private

  def types
    {
      conversation_message: ConversationMailer,
      join_notice:          ProjectMembershipMailer,
      unsubscribe_notice:   ProjectMembershipMailer,
      sign_up_confirmation: UserMailer,
      reset_password:       UserMailer,
    }
  end

  def type? type
    types.key?(type.to_sym) or raise ArgumentError, "unknown email type: #{type}"
  end

end
