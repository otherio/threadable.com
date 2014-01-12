class Covered::Group < Covered::Model

  self.model_name = ::Group.model_name

  def initialize covered, group_record
    @covered, @group_record = covered, group_record
  end
  attr_reader :group_record

  delegate *%w{
    id
    to_param
    name
    email_address_tag
    color
    errors
    new_record?
    persisted?
    destroy
  }, to: :group_record

  def group_id
    group_record.id
  end

  let(:members){ Members.new(self) }
  let(:conversations){ Conversations.new(self) }
  let(:tasks){ Tasks.new(self) }

  def organization_record
    group_record.organization
  end

  def organization
    @organization ||= Covered::Organization.new(covered, organization_record)
  end

  def email_address
    "#{organization.email_address_username}+#{email_address_tag}@#{covered.email_host}"
  end

  def task_email_address
    "#{organization.email_address_username}+#{email_address_tag}+task@#{covered.email_host}"
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
