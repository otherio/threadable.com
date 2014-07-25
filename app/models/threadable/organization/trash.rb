class Threadable::Organization::Trash

  def initialize organization
    @organization = organization
  end
  attr_reader :organization, :threadable
  delegate :threadable, :organization_record, to: :organization

  include Threadable::Conversation::Scopes

  private

  def conversations_scope
    organization_record.conversations.trashed.grouped
  end

  def tasks_scope
    organization_record.tasks.trashed.grouped
  end

end
