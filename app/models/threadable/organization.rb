class Threadable::Organization < Threadable::Model

  SPECIAL_EMAIL_ADDRESS_TAGS = %w{ task }.freeze

  def self.model_name
    ::Organization.model_name
  end

  def initialize threadable, organization_record
    @threadable, @organization_record = threadable, organization_record
  end
  attr_reader :organization_record

  delegate(*%w{
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
    hold_all_messages?
    trusted?
    plan
    public_signup?
    billforward_account_id
    billforward_subscription_id
    daily_active_users
    account_type
  }, to: :organization_record)

  let(:settings) do
    Threadable::Organization::Settings.new(
      self,
      organization_membership_permission: {options: [:member, :owner], default: :member, membership_required: :paid},
      group_membership_permission:        {options: [:member, :owner], default: :member, membership_required: :paid},
      group_settings_permission:          {options: [:member, :owner], default: :member, membership_required: :paid},
    )
  end

  ::Organization::PLANS.each do |plan|
    define_method("#{plan}?"){ self.plan == plan }
  end

  ::Organization::ACCOUNT_TYPES.each do |account_type|
    define_method("#{account_type}?"){ self.account_type == account_type }
  end

  let(:email_domains) { Threadable::Organization::EmailDomains.new(self) }

  def email_address
    internal_email_address
  end

  def task_email_address
    internal_task_email_address
  end

  def internal_email_address
    self.groups.primary.internal_email_address
  end

  def internal_task_email_address
    self.groups.primary.internal_task_email_address
  end

  def email_addresses
    [email_address, task_email_address]
  end

  def formatted_email_address
    self.groups.primary.formatted_email_address
  end

  def formatted_task_email_address
    self.groups.primary.formatted_task_email_address
  end

  def email_host
    return @email_host if @email_host
    outgoing_domain = email_domains.outgoing
    @email_host = outgoing_domain.present? ? outgoing_domain.domain : internal_email_host
  end

  def internal_email_host
    "#{email_address_username}.#{threadable.email_host}"
  end

  def no_subdomain_email_address
    "#{email_address_username}@#{threadable.email_host}"
  end

  def list_id
    "#{name} <#{email_address_username}.#{threadable.email_host}>"
  end

  # collections
  let(:members)             { Threadable::Organization::Members       .new(self) }
  let(:conversations)       { Threadable::Organization::Conversations .new(self) }
  let(:messages)            { Threadable::Organization::Messages      .new(self) }
  let(:tasks)               { Threadable::Organization::Tasks         .new(self) }
  let(:incoming_emails)     { Threadable::Organization::IncomingEmails.new(self) }
  let(:held_messages)       { Threadable::Organization::HeldMessages  .new(self) }
  let(:groups)              { Threadable::Organization::Groups        .new(self) }
  let(:unrestricted_groups) { Threadable::Organization::Groups        .new(self, unrestricted: true) }

  # scopes
  include Threadable::Conversation::Scopes
  private
  def conversations_scope
    organization_record.conversations.untrashed
  end
  def tasks_scope
    organization_record.tasks.untrashed
  end
  public
  let(:my)       { Threadable::Organization::My   .new(self) }
  let(:trash)    { Threadable::Organization::Trash.new(self) }

  def has_email_address? email_address
    email_address = email_address.address if email_address.is_a? Mail::Address
    all_email_addresses.include? email_address
  end

  def matches_email_address? email_address
    email_address = Mail::Address.new(email_address) unless email_address.is_a? Mail::Address
    domain = email_address.domain.split('.').last(2).join('.')
    domain = 'localhost' if domain =~ /localhost$/ # for dev
    host = email_address.domain.split('.').first
    if (Threadable::Class::EMAIL_HOSTS.values.include? domain) &&
      ( (email_address.local.split(/(\+|--)/).first == slug) || (host == slug) )
      return true
    end
    has_email_address? email_address
  end

  def all_email_addresses
    return @all_email_addresses if @all_email_addresses
    @all_email_addresses = groups.all.map do |group|
      [group.email_address, group.task_email_address]
    end
    @all_email_addresses << [email_address, task_email_address, no_subdomain_email_address]
    @all_email_addresses.flatten!
  end

  def email_address_tags email_addresses
    email_addresses = [email_addresses] unless email_addresses.kind_of?(Array)

    domains = email_domains.all.map(&:domain)
    domains << internal_email_host

    tags = email_addresses.map do |email_address|
      local, host = email_address.strip_non_ascii.downcase.split('@')
      local.gsub!(/\./, '-')
      local_components = local.split(/(?:\+|--)/) - SPECIAL_EMAIL_ADDRESS_TAGS
      no_subdomain_addresses = threadable.email_hosts.map{ |host| "#{email_address_username}@#{host}"}

      if threadable.email_hosts.include?(host)
        if local == email_address_username
          groups.primary.email_address_tag
        elsif local_components[0] == email_address_username
          local_components[1..-1]
        end
      elsif domains.include?(host)
        # the whole local part
        local_components[0]
      end
    end.flatten

    tags.compact.uniq
  end

  def owner_ids
    organization_record.memberships.who_are_owners.map(&:user_id)
  end

  def google_user
    return nil unless organization_record.google_user
    Threadable::User.new(threadable, organization_record.google_user)
  end

  def google_user= user
    user.can?(:be_google_user_for, self) or raise Threadable::AuthorizationError, 'User does not have permission to be the google apps domain user'
    external_auth = user.external_authorizations.find_by_provider('google_oauth2')
    raise Threadable::ExternalServiceError, 'User does not have a Google authorization' unless external_auth.present?
    raise Threadable::ExternalServiceError, "User's Google authorization does not have a domain. Are they a google apps domain admin?" unless external_auth.domain.present?

    organization_record.update_attributes(google_user: user.user_record)
  end

  # TODO/LIES remove me in favor of a rails json view file
  # Updated lies: we have serializers. This might do nothing.
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
    members.current_member.can?(:change_settings_for, self) or raise Threadable::AuthorizationError, 'You do not have permission to change settings for this organization'
    Update.call(self, attributes)
  end

  def admin_update attributes
    threadable.current_user.admin? or raise Threadable::AuthorizationError, 'You do not have permission to change settings for this organization'
    Update.call(self, attributes)
  end

  def application_update options
    ApplicationUpdate.call(self, options)
  end

  def hold_all_messages!
    organization_record.update!(hold_all_messages: true)
    self
  end

  def paid!
    organization_record.update!(plan: :paid)
  end

  def free!
    organization_record.update!(plan: :free)
  end

  def destroy!
    organization_record.destroy!
  end

  def reload
    organization_record.reload
    self
  end

  def inspect
    %(#<#{self.class} organization_id: #{id.inspect}, name: #{name.inspect}>)
  end
end

