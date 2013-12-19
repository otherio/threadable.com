require_dependency 'covered/incoming_email'

class Covered::IncomingEmail::Process < MethodObject

  def call incoming_email
    @incoming_email, @covered = incoming_email, incoming_email.covered
    raise ArgumentError, "IncomingEmail #{@incoming_email.id.inspect} has already been processed" if incoming_email.processed?

    Covered.transaction do
      @incoming_email.find_project!
      return bounce! if @incoming_email.bounceable?
      @incoming_email.find_message!
      @incoming_email.find_creator!
      @incoming_email.find_parent_message!
      @incoming_email.find_conversation!

      sign_in_as_creator!

      return deliver! if @incoming_email.deliverable?
      return hold!    if @incoming_email.holdable?
      return bounce!
    end
  end

  def sign_in_as_creator!
    @covered.current_user_id = @incoming_email.creator.try(:id)
  end

  def bounce!
    @incoming_email.bounce!
    @incoming_email.processed!
  end

  def hold!
    @incoming_email.hold!
    @incoming_email.processed!
  end

  def deliver!
    @incoming_email.deliver!
    @incoming_email.processed!
  end

end
