raise "refusing to load file #{__FILE__} in #{Rails.env}" if Rails.env.production?

require 'timecop'

class FixtureBuilder

  def self.build(&block)
    new.instance_eval(&block)
  end

  def threadable
    @threadable ||= Threadable.new(
      host: defined?(Capybara) ? Capybara.server_host : 'example.com',
      port: defined?(Capybara) ? Capybara.server_port : 80,
    )
  end
  delegate :current_user, to: :threadable

  def as_an_admin
    threadable.current_user_id = ::User.find_by_email_address!('jared@other.io').id
    yield
  ensure
    threadable.current_user_id = nil
  end

  def as email_address
    threadable.current_user_id = member(email_address).user_id
    yield
  ensure
    @current_member = nil
    threadable.current_user_id = nil
  end

  def create_organization attributes
    @organization.nil? or raise "you can only create one organization in a fixture builder"
    @organization = threadable.organizations.create! attributes.merge(add_current_user_as_a_member: false, populate_starter_data: false)
  end

  def organization
    @organization or raise 'please create an organization first'
  end

  def add_member name, email_address, owner = false
    member = organization.members.add(name: name, email_address: email_address, role: owner ? 0 : 1)
    member.user.update(:munge_reply_to => true)
    @members ||= {}
    @members[email_address] = member
  end

  def remove_member email_address
    member = organization.members.find_by_email_address(email_address)
    member.remove
  end

  def current_member
    organization.members.current_member
  end

  def member email_address
    @members ||= {}
    @members[email_address] or raise ArgumentError, "member not found for #{email_address.inspect}"
  end

  def create_group attributes
    organization.groups.create!(attributes)
  end

  def add_domain domain, outgoing=false
    organization.email_domains.add(domain, outgoing)
  end

  def remove_conversation_from_group conversation, group
    require_current_user_be_web_enabled!
    conversation = conversation.conversation if conversation.respond_to?(:conversation)
    conversation.groups.remove(group)
  end

  def add_conversation_to_group conversation, group
    require_current_user_be_web_enabled!
    conversation = conversation.conversation if conversation.respond_to?(:conversation)
    conversation.groups.add(group)
  end

  def add_member_to_group group_slug, email_address
    require_current_user_be_web_enabled!
    group = organization.groups.find_by_slug!(group_slug)
    group.members.add(organization.members.find_by_email_address(email_address))
  end

  def remove_member_from_group group_slug, email_address
    require_current_user_be_web_enabled!
    group = organization.groups.find_by_slug!(group_slug)
    group.members.remove(organization.members.find_by_email_address(email_address))
  end

  def set_group_to_summary group_slug
    require_current_user_be_web_enabled!
    group = organization.groups.find_by_slug!(group_slug)
    group.members.current_member.gets_in_summary!
  end

  def web_enable! email_address
    threadable.users.find_by_email_address!(email_address).update!(
      password: 'password',
      password_confirmation: 'password'
    )
  end

  def require_current_user_be_web_enabled!
    current_user.web_enabled? or raise "the current user #{current_user.inspect} must be web enabled to do this action."
  end

  def confirm_email_address! email_address
    threadable.users.find_by_email_address!(email_address).email_addresses.find_by_address!(email_address).confirm!
  end

  def create_conversation options
    message_options = options.slice!(:subject, :groups)
    options[:creator] = current_user
    conversation = organization.conversations.create!(options)
    create_message conversation, message_options
  end

  def create_message conversation, options
    conversation.messages.create!(options.merge(creator: current_user))
  end

  def attachment path, content_type, binary=true
    attachments_path = Rails.root + 'lib/fixtures/attachments'
    file = attachments_path + path
    {
      content:  file.read,
      filename: file.basename.to_s,
      mimetype: content_type,
      size:     file.size,
      content_id: "<#{path.gsub(/\W/, '')}contentid>",
    }
  end

  def reply_to message, options
    message.conversation.messages.create!(options.merge(parent_message: message, creator: current_user))
  end

  def mute_conversation conversation
    conversation = conversation.conversation if conversation.respond_to?(:conversation)
    conversation.mute!
  end

  def trash_conversation conversation
    conversation = conversation.conversation if conversation.respond_to?(:conversation)
    conversation.trash!
  end

  def create_task subject, groups = nil
    organization.tasks.create!(subject: subject, creator: current_user, groups: groups)
  end

  def add_doer_to_task task, email_address
    task.doers.add member(email_address)
  end

  def mark_task_as_done task
    task.done!
  end

  def set_avatar! filename, options={}
    require_current_user_be_web_enabled!
    member = options.key?(:for) ? member(options[:for]) : current_member
    member.update! avatar_url: "/fixture_images/#{filename}"
  end

  def dismiss_welcome_modal!
    require_current_user_be_web_enabled!
    current_user.dismissed_welcome_modal!
  end

  def add_email_address! email_address, primary=false
    require_current_user_be_web_enabled!
    current_user.email_addresses.add! email_address, primary
  end

  def unsubscribe_from_organization_email!
    current_member.unsubscribe!
  end

end
