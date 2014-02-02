require_dependency 'threadable/incoming_email'

class Threadable::IncomingEmail::Process < MethodObject

  def call incoming_email
    @incoming_email, @threadable = incoming_email, incoming_email.threadable
    raise ArgumentError, "IncomingEmail #{@incoming_email.id.inspect} has already been processed" if incoming_email.processed?

    Threadable.transaction do
      @incoming_email.find_organization!
      @incoming_email.find_groups!
      if @incoming_email.bounceable?
        bounce!
        return process!
      end
      @incoming_email.find_message!
      @incoming_email.find_creator!
      @incoming_email.find_parent_message!
      @incoming_email.find_conversation!

      sign_in_as_creator!

      duplicate = @incoming_email.message.present?

      deliver! if @incoming_email.deliverable?
      hold!    if @incoming_email.holdable?
      drop!    if @incoming_email.droppable?
      bounce!  if @incoming_email.bounceable?


      if !duplicate && @threadable.current_user
        run_commands!
      end

      return process!
    end
  end

  def sign_in_as_creator!
    @threadable.current_user_id = @incoming_email.creator.try(:id)
  end

  def bounce!
    @incoming_email.bounce!
  end

  def hold!
    @incoming_email.hold!
  end

  def deliver!
    @incoming_email.deliver!
  end

  def drop!
    @incoming_email.drop!
  end

  def process!
    @incoming_email.processed!
  end

  def run_commands!
    RunCommandsFromEmailMessageBody.call(@incoming_email.conversation, @incoming_email.stripped_plain) unless @incoming_email.stripped_plain.nil?
  end

end
