class FixtureBuilder

  def self.build(&block)
    new.instance_eval(&block)
  end

  def covered
    @covered ||= new_covered
  end
  delegate :current_user, to: :covered

  def new_covered options={}
    Covered.new options.merge(
      host: defined?(Capybara) ? Capybara.server_host : 'example.com',
      port: defined?(Capybara) ? Capybara.server_port : 80,
    )
  end
  private :new_covered


  def get_user email_address
    @users_cache ||= {}
    @users_cache[email_address] ||= ::User.find_by_email_address!(email_address)
  end

  def as_an_admin
    @covered = new_covered(current_user_id: get_user('jared@other.io').id)
    yield
  ensure
    @covered = nil
  end

  def as email_address
    @covered = new_covered(current_user_id: get_user(email_address).id)
    yield
  ensure
    @covered = nil
  end

  def create_project attributes
    @project.nil? or raise "you can only create one project in a fixture builder"
    @project = covered.projects.create! attributes.merge(add_current_user_as_a_member: false)
  end

  def project
    @project or raise 'please create a project first'
  end

  def add_member name, email_address
    project.members.add(name: name, email_address: email_address)
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
    subject = options.fetch(:subject)
    conversation = project.conversations.create!(subject: subject, creator: current_user)
    create_message conversation, options
  end

  def create_message conversation, options
    message = conversation.messages.create!(options.merge(creator: current_user))
  end

  def reply_to message, options
    message.conversation.messages.create!(options.merge(parent_message: message, creator: current_user))
  end

  def create_task subject
    project.tasks.create!(subject: subject, creator: current_user)
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

  def unsubscribe_from_project_email! project=self.project
    membership = project.members.find_by_user_id! current_user.id
    membership.unsubscribe!
  end


end
