class TestEnvironment::FixtureBuilder

  def self.build(&block)
    Class.new(self).class_eval(&block).new.build
  end

  def initialize(&block)
    instance_eval(&block) if block_given?
  end

  def project
    @project or raise "please define a project first"
  end

  def users
    @users ||= {}
  end

  def user user_name
    users.fetch user_name
  end

  def conversations
    @conversations ||= {}
  end

  def tasks
    @tasks ||= {}
  end

  def messages
    @messages ||= []
  end

  def create_user name, email
    users[name] = FactoryGirl.create(:user, email: email, name: name, password: 'password')
  end

  def invite_user name, email
    create_user name, email
  end

  def set_avatar email, filename
    User.with_email(email).first!.update_attribute(:avatar_url, "/assets/fixtures/#{filename}")
  end

  def accept_invite name
    user(name).confirm!
    project.members << user(name)
  end

  def send_message(attributes)
    subject = attributes[:subject].sub(/^re: /i, '')
    creator = attributes[:user] = user(attributes[:user]) if attributes[:user]
    conversation = conversations[subject] ||= project.conversations.create!(
      subject: subject,
      creator: creator,
    )
    conversation or raise "cant find conversation by subject: #{subject}"
    message = conversation.messages.create!(attributes)
    messages << messages
    message
  end

  def create_task(user_name, subject)
    creator = user(user_name)
    raise "task already exists" if conversations[subject]
    task = project.tasks.create!(subject: subject, creator: creator)
    conversations[subject] = task
    tasks[subject] = task
  end

  def add_doer_to_task user_name, subject
    tasks[subject].doers << user(user_name)
  end

  def complete_task user_name, subject
    tasks[subject].done! user(user_name)
  end

  def unsubscribe_from_project_email user_name
    project_membership = user(user_name).project_memberships.where(project_id: project.id).first
    project_membership.gets_email = false
    project_membership.save!
  end

end
