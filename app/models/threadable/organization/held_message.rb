require_dependency 'threadable/organization'

class Threadable::Organization::HeldMessage < Threadable::Model

  def initialize organization, incoming_email
    @organization = organization
    @threadable = organization.threadable
    @incoming_email = incoming_email
  end
  attr_reader :organization, :incoming_email

  delegate *%w{
    id
    from
    subject
    to_param
  }, to: :incoming_email

  def accept!
    incoming_email.unhold!
    Threadable.after_transaction do
      AcceptHeldIncomingEmailWorker.perform_async(threadable.env, id)
    end
    self
  end

  def reject!
    incoming_email.unhold!
    Threadable.after_transaction do
      RejectHeldIncomingEmailWorker.perform_async(threadable.env, id)
    end
    self
  end

end
