require_dependency 'covered/project'

class Covered::Project::HeldMessage < Covered::Model

  def initialize project, incoming_email
    @project = project
    @covered = project.covered
    @incoming_email = incoming_email
  end
  attr_reader :project, :incoming_email

  delegate *%w{
    id
    from
    subject
    to_param
  }, to: :incoming_email

  def accept!
    incoming_email.unhold!
    AcceptHeldIncomingEmailWorker.perform_async(covered.env, id)
    self
  end

  def reject!
    incoming_email.unhold!
    RejectHeldIncomingEmailWorker.perform_async(covered.env, id)
    self
  end

end
