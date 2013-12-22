require_dependency 'covered/project'

class Covered::Project::HeldMessages < Covered::Collection

  def initialize project
    @project = project
    @covered = project.covered
  end
  attr_reader :project

  def all
    held_messages_for project.incoming_emails.held
  end

  def find_by_id! id
    held_message_for project.incoming_emails.find_by_id!(id)
  end

  def count
    project.project_record.incoming_emails.where(held: true).count
  end

  private

  def held_message_for incoming_email
    Covered::Project::HeldMessage.new(project, incoming_email) if incoming_email
  end

  def held_messages_for incoming_emails
    incoming_emails.map{ |incoming_email| held_message_for incoming_email }
  end

end
