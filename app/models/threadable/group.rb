class Threadable::Group < Threadable::Model

  self.model_name = ::Group.model_name

  def initialize threadable, group_record
    @threadable, @group_record = threadable, group_record
  end
  attr_reader :group_record

  delegate *%w{
    id
    to_param
    slug
    name
    email_address_tag
    subject_tag
    color
    errors
    new_record?
    persisted?
    destroy
    auto_join
  }, to: :group_record

  def group_id
    group_record.id
  end

  # collections
  let(:members)      { Threadable::Group::Members.new(self) }
  let(:conversations){ Threadable::Group::Conversations.new(self) }
  let(:tasks)        { Threadable::Group::Tasks.new(self) }


  # scopes
  include Threadable::Conversation::Scopes
  private
  def conversations_scope
    group_record.conversations
  end
  def tasks_scope
    group_record.tasks
  end
  public


  def organization_record
    group_record.organization
  end

  def organization
    @organization ||= Threadable::Organization.new(threadable, organization_record)
  end

  def email_address
    "#{organization.email_address_username}+#{email_address_tag}@#{threadable.email_host}"
  end

  def task_email_address
    "#{organization.email_address_username}+#{email_address_tag}+task@#{threadable.email_host}"
  end

  def formatted_email_address
    FormattedEmailAddress.new(
      display_name: "#{organization.name}: #{name}",
      address: email_address,
    ).to_s
  end

  def formatted_task_email_address
    FormattedEmailAddress.new(
      display_name: "#{organization.name}: #{name} Tasks",
      address: task_email_address,
    ).to_s
  end

  def update attributes
    !!group_record.update_attributes(attributes)
  end

  def inspect
    %(#<#{self.class} group_id: #{id.inspect}, name: #{name.inspect}>)
  end

end
