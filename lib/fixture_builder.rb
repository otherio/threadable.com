class FixtureBuilder

  def self.build(&block)
    new.instance_eval(&block)
  end

  def covered
    @covered ||= Covered.new(
      host: defined?(Capybara) ? Capybara.server_host : 'example.com',
      port: defined?(Capybara) ? Capybara.server_port : 80,
    )
  end
  delegate :current_user, to: :covered


  def get_user email_address
    @users_cache ||= {}
    @users_cache[email_address] ||= ::User.find_by_email_address!(email_address)
  end

  def as_an_admin
    covered.current_user_id = get_user('jared@other.io').id
    yield
  ensure
    covered.current_user_id = nil
  end

  def as email_address
    covered.current_user_id = get_user(email_address).id
    yield
  ensure
    covered.current_user_id = nil
  end

  def create_organization attributes
    @organization.nil? or raise "you can only create one organization in a fixture builder"
    @organization = covered.organizations.create! attributes.merge(add_current_user_as_a_member: false)
  end

  def organization
    @organization or raise 'please create a organization first'
  end

  def add_member name, email_address
    organization.members.add(name: name, email_address: email_address)
  end

  def create_group name
    organization.groups.create!(name: name)
  end

  def remove_conversation_from_group message, group
    message.conversation.groups.remove(group)
  end

  def add_member_to_group email_address_tag, email_address
    group = organization.groups.find_by_email_address_tag(email_address_tag)
    group.members.add(organization.members.find_by_email_address(email_address))
  end

  def web_enable! email_address
    covered.users.find_by_email_address!(email_address).update!(
      password: 'password',
      password_confirmation: 'password'
    )
  end

  def require_current_user_be_web_enabled!
    current_user.web_enabled? or raise "the current user #{current_user.inspect} must be web enabled to do this action."
  end

  def confirm_email_address! email_address
    covered.users.find_by_email_address!(email_address).email_addresses.find_by_address!(email_address).confirm!
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

  def reply_to message, options
    message.conversation.messages.create!(options.merge(parent_message: message, creator: current_user))
  end

  def mute_conversation conversation
    conversation.mute!
  end

  def create_task subject
    organization.tasks.create!(subject: subject, creator: current_user)
  end

  def add_doer_to_task task, email_address
    user_record = get_user(email_address)
    user = Covered::User.new(covered, user_record)
    task.doers.add user
  end

  def mark_task_as_done task
    task.done!
  end

  def set_avatar! filename
    require_current_user_be_web_enabled!
    current_user.update! avatar_url: "/fixture_images/#{filename}"
  end

  def add_email_address! email_address, primary=false
    require_current_user_be_web_enabled!
    current_user.email_addresses.add! email_address, primary
  end

  def unsubscribe_from_organization_email! organization=self.organization
    membership = organization.members.find_by_user_id! current_user.id
    membership.unsubscribe!
  end


end
