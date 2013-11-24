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

  def sign_up name, email_address
    user = covered.sign_up(
      name: name,
      email_address: email_address,
      password: 'password',
      password_confirmation: 'password',
    )
    user.errors.empty? or raise "'failed to sign up #{name}, #{email_address}: #{user.errors.full_messages.to_sentence}"
  end

  def get_user email_address
    @users_cache ||= {}
    @users_cache[email_address] ||= ::User.find_by_email_address!(email_address)
  end

  def as email_address
    @covered = Covered.new covered.env.merge(current_user_id: get_user(email_address).id)
    yield
  ensure
    @covered = nil
  end

  def create_project attributes
    @project = current_user.projects.create! attributes
  end

  def project
    @project or raise 'please create a project first'
  end

  def add_member name, email_address
    project.members.add(name: name, email_address: email_address)
  end

  def create_conversation options
    subject = options.fetch(:subject)
    conversation = project.conversations.create!(subject: subject)
    create_message conversation, options
  end

  def create_message conversation, options
    message = conversation.messages.create!(options)
  end

  def reply_to message, options
    message.conversation.messages.create!(options.merge(parent_message: message))
  end

  def create_task subject
    project.tasks.create!(subject: subject)
  end

  def add_doer_to_task task, email_address
    user_record = get_user(email_address)
    user = Covered::User.new(covered, user_record)
    task.doers.add user
  end

  def mark_task_as_done task
    task.done!
  end

  def confirm_account!
    current_user.confirm!
  end

  def web_enable!
    current_user.update!(password: 'password', password_confirmation: 'password')
  end

  def set_avatar! filename
    current_user.update! avatar_url: "/fixture_images/#{filename}"
  end

  def add_email_address! email_address, primary=false
    current_user.email_addresses.add! email_address, primary
  end

  def unsubscribe_from_project_email! project=self.project
    membership = project.members.find_by_user_id! current_user.id
    membership.unsubscribe!
  end

  def web_enable email_address
    as email_address do
      web_enable!
    end
  end

end
