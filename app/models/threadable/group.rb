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
    alias_email_address
    webhook_url
    new_record?
    persisted?
    destroy
    auto_join?
    hold_messages?
  }, to: :group_record

  def group_id
    group_record.id
  end

  # collections
  let(:members){ Members.new(self) }
  let(:conversations){ Conversations.new(self) }
  let(:tasks){ Tasks.new(self) }


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
    if alias_email_address.present?
      alias_email_address_object.address
    else
      internal_email_address
    end
  end

  def task_email_address
    if alias_email_address.present?
      "#{alias_email_address_object.local}-task@#{alias_email_address_object.domain}"
    else
      internal_task_email_address
    end
  end

  def internal_email_address
    "#{organization.email_address_username}+#{email_address_tag}@#{threadable.email_host}"
  end

  def internal_task_email_address
    "#{organization.email_address_username}+#{email_address_tag}+task@#{threadable.email_host}"
  end

  def formatted_email_address
    FormattedEmailAddress.new(
      display_name: email_address_display_name,
      address: email_address,
    ).to_s
  end

  def formatted_task_email_address
    FormattedEmailAddress.new(
      display_name: email_address_display_name(true),
      address: task_email_address,
    ).to_s
  end

  def update attributes
    group_record.update_attributes!(attributes)
  end

  def == other
    (self.class === other || other.class === self) && self.group_id == other.group_id
  end

  def inspect
    %(#<#{self.class} group_id: #{id.inspect}, name: #{name.inspect}>)
  end

  private

  def alias_email_address_object
    @alias_email_address_object ||= Mail::Address.new(alias_email_address)
  end

  def email_address_display_name task=false
    display_name = if alias_email_address.present?
      alias_email_address_object.display_name
    else
      "#{organization.name}: #{name}"
    end
    display_name += " Tasks" if task && display_name
    display_name
  end

end
