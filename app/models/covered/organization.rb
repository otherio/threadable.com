class Covered::Organization < Covered::Model

  def self.model_name
    ::Organization.model_name
  end

  def initialize covered, organization_record
    @covered, @organization_record = covered, organization_record
  end
  attr_reader :organization_record

  delegate *%w{
    id
    to_param
    name
    short_name
    slug
    email_address_username
    subject_tag
    description
    errors
    new_record?
    persisted?
  }, to: :organization_record

  def email_address
    "#{organization_record.email_address_username}@#{covered.email_host}"
  end

  def task_email_address
    "#{organization_record.email_address_username}+task@#{covered.email_host}"
  end

  def email_addresses
    [email_address, task_email_address]
  end

  def formatted_email_address
    FormattedEmailAddress.new(display_name: name, address: email_address).to_s
  end

  def formatted_task_email_address
    FormattedEmailAddress.new(display_name: "#{name} Tasks", address: task_email_address).to_s
  end

  def list_id
    "#{name} <#{email_address_username}.#{covered.email_host}>"
  end

  # collections
  let(:members)        { Covered::Organization::Members       .new(self) }
  let(:conversations)  { Covered::Organization::Conversations .new(self) }
  let(:messages)       { Covered::Organization::Messages      .new(self) }
  let(:tasks)          { Covered::Organization::Tasks         .new(self) }
  let(:incoming_emails){ Covered::Organization::IncomingEmails.new(self) }
  let(:held_messages)  { Covered::Organization::HeldMessages  .new(self) }
  let(:groups)         { Covered::Organization::Groups        .new(self) }

  # scopes
  include Covered::Conversation::Scopes
  private
  def conversations_scope
    organization_record.conversations
  end
  def tasks_scope
    organization_record.tasks
  end
  public
  let(:my)       { Covered::Organization::My       .new(self) }
  let(:ungrouped){ Covered::Organization::Ungrouped.new(self) }


  # TODO remove me in favor of a rails json view file
  def as_json options=nil
    {
      id:          id,
      param:       to_param,
      name:        name,
      short_name:  short_name,
      slug:        slug,
      subject_tag: subject_tag,
      description: description,
    }
  end

  def update attributes
    Update.call(self, attributes)
  end

  def destroy!
    organization_record.destroy!
  end

  def inspect
    %(#<#{self.class} organization_id: #{id.inspect}, name: #{name.inspect}>)
  end
end

