require_dependency 'threadable/organization'

class Threadable::Organization::HeldMessages < Threadable::Collection

  def initialize organization
    @organization = organization
    @threadable = organization.threadable
  end
  attr_reader :organization

  def all
    held_messages_for organization.incoming_emails.held
  end

  def find_by_id! id
    held_message_for organization.incoming_emails.find_by_id!(id)
  end

  def count
    organization.organization_record.incoming_emails.where(held: true).count
  end

  private

  def held_message_for incoming_email
    Threadable::Organization::HeldMessage.new(organization, incoming_email) if incoming_email
  end

  def held_messages_for incoming_emails
    incoming_emails.map{ |incoming_email| held_message_for incoming_email }
  end

end
