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

  def accept_invite name
    project.members << users[name]
  end

  def send_message(attributes)
    subject = attributes[:subject].sub(/^re: /i, '')
    conversation = conversations[subject] ||= project.conversations.find_or_create_by_subject(subject)
    conversation or raise "cant find conversation by subject: #{subject}"
    messages << conversation.messages.create!(attributes)
  end

  def create_task(subject)
    conversations[subject] and raise "conversation already exists"
    task = project.tasks.create!(subject: subject)
    conversations[subject] = task
    tasks[subject] = task
  end

  def add_doer_to_task user, subject
    tasks[subject].doers << user
  end

  def complete_task subject
    tasks[subject].done!
  end

end
