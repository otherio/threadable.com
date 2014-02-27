class Threadable::Organization < Threadable::Model

  def self.model_name
    ::Organization.model_name
  end

  def initialize threadable, organization_record
    @threadable, @organization_record = threadable, organization_record
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
    trusted?
  }, to: :organization_record

  def email_address
    # this will soon do aliasing
    internal_email_address
  end

  def task_email_address
    # this will soon do aliasing
    internal_task_email_address
  end

  def internal_email_address
    "#{email_address_username}@#{threadable.email_host}" if email_address_username.present?
  end

  def internal_task_email_address
    "#{email_address_username}+task@#{threadable.email_host}" if email_address_username.present?
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
    "#{name} <#{email_address_username}.#{threadable.email_host}>"
  end

  # collections
  let(:members)        { Threadable::Organization::Members       .new(self) }
  let(:conversations)  { Threadable::Organization::Conversations .new(self) }
  let(:messages)       { Threadable::Organization::Messages      .new(self) }
  let(:tasks)          { Threadable::Organization::Tasks         .new(self) }
  let(:incoming_emails){ Threadable::Organization::IncomingEmails.new(self) }
  let(:held_messages)  { Threadable::Organization::HeldMessages  .new(self) }
  let(:groups)         { Threadable::Organization::Groups        .new(self) }

  # scopes
  include Threadable::Conversation::Scopes
  private
  def conversations_scope
    organization_record.conversations
  end
  def tasks_scope
    organization_record.tasks
  end
  public
  let(:my)       { Threadable::Organization::My       .new(self) }
  let(:ungrouped){ Threadable::Organization::Ungrouped.new(self) }

  def has_email_address? email_address
    email_address = email_address.address if email_address.is_a? Mail::Address
    all_email_addresses.include? email_address
  end

  def matches_email_address? email_address
    email_address = Mail::Address.new(email_address) unless email_address.is_a? Mail::Address
    if (Threadable::Class::EMAIL_HOSTS.values.include? email_address.domain) && (email_address.local.split(/(\+|--)/).first == slug)
      return true
    end
    has_email_address? email_address
  end

  def all_email_addresses
    return @all_email_addresses if @all_email_addresses
    @all_email_addresses = groups.all.map do |group|
      [group.email_address, group.task_email_address]
    end
    @all_email_addresses << [email_address, task_email_address]
    @all_email_addresses.flatten!
  end

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

