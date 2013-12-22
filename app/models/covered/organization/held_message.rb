require_dependency 'covered/organization'

class Covered::Organization::HeldMessage < Covered::Model

  def initialize organization, incoming_email
    @organization = organization
    @covered = organization.covered
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
    Covered.after_transaction do
      AcceptHeldIncomingEmailWorker.perform_async(covered.env, id)
    end
    self
  end

  def reject!
    incoming_email.unhold!
    Covered.after_transaction do
      RejectHeldIncomingEmailWorker.perform_async(covered.env, id)
    end
    self
  end

end
