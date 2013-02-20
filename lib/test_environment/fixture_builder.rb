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
    users[name] = User.create!(email: email, name: name, password: 'password')
  end

  def invite_user name, email
    create_user name, email
  end

  def set_avatar email, filename
    User.where(email: email).first.update_attribute(:avatar_url, "http://localhost:3000/assets/fixtures/#{filename}")
  end

  def accept_invite name
    project.members << users[name]
  end

  def send_message(attributes)
    subject = attributes[:subject].sub(/^re: /i, '')
    creator = attributes[:user]
    conversation = conversations[subject] ||= project.conversations.create!(
      subject: subject,
      creator: creator,
    )
    conversation or raise "cant find conversation by subject: #{subject}"
    messages << conversation.messages.create!(attributes)
  end

  def create_task(creator, subject)
    raise "task already exists" if conversations[subject]
    task = project.tasks.create!(subject: subject, creator: creator)
    conversations[subject] = task
    tasks[subject] = task
  end

  def add_doer_to_task user, subject
    tasks[subject].doers << user
  end

  def complete_task user, subject
    tasks[subject].done! user
  end

end
