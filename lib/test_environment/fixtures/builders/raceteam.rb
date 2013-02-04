Class.new do

  def go!
    @users = {}

    # Alice signs up
    @users[:alice] = create_user('Alice Neilson', "alice@ucsd.edu")

    # Alice creates a project
    @project = Project.create!(
      name: 'UCSD Electric Racingz',
      description: 'Senior engineering electric race team!'
    )
    @project.project_memberships.create!(user: @users[:alice])

    # Alice invites her project mates
    @users[:tom]     = invite_user('Tom Canver',      'tom@ucsd.edu')
    @users[:yan]     = invite_user('Yan Hzu',         'yan@ucsd.edu')
    @users[:bethany] = invite_user('Bethany Pattern', 'bethany@ucsd.edu')
    @users[:bob]     = invite_user('Bob Cauchois',    'bob@ucsd.edu')

    # Alice sends a welcome email
    send_message(
      user: @users[:alice],
      reply: false,
      subject: 'Welcome to our new Multify project!',
      body: 'Hey all! I think we should try this way to organize our conversation and work for the car. Thanks for joining up!'
    )

    # Bethany replies to the welcome email
    send_message(
      user: @users[:bethany],
      reply: true,
      subject: 'RE: Welcome to our new Multify project!',
      body: 'Yay! You go Alice. This tool looks radder than an 8-legged panda.',
    )

    send_message(
      user: @users[:tom],
      reply: false,
      subject: 'How are we going to build the body?',
      body: "I'm not 100% clear on the right way to go for this, but we should figure out if we're going to make the body out of carbon or buy a giant boat and cut it up or whatever.",
    )


    # Alice starts making some tasks
    create_task('layup body carbon')
    create_task('install mirrors')
    create_task('trim body panels')
    create_task('make wooden form for carbon layup' )


    send_message(
      subject: 'layup body carbon',
      body: "Some stuff about how we have decided on a course of action for this body.\nSo, let's do some carbon layup!",
      user: @users[:alice],
      reply: false,
    )

    send_message(
      subject: 'RE: layup body carbon',
      body: "Totally!\nI'm thinking we can do this on our first January workday. I'll make sure we get the supplies in time",
      user: @users[:tom],
      reply: true,
    )
    add_doer_to_task(@users[:tom], 'layup body carbon')

    create_task('get epoxy')
    create_task('get release agent')
    create_task('get carbon and fiberglass')

    send_message(
      subject: 'RE: layup body carbon',
      body: "I'm so there! Also, I think I can probably pick up some of those supplies from a friend, who was trying to make a kayak.",
      user: @users[:yan],
      reply: true,
    )
    add_doer_to_task(@users[:yan], 'layup body carbon')

    add_doer_to_task(@users[:tom], 'get epoxy')
    add_doer_to_task(@users[:tom], 'get release agent')
    add_doer_to_task(@users[:yan], 'get release agent')
    add_doer_to_task(@users[:tom], 'get carbon and fiberglass')

    complete_task('get epoxy')
    complete_task('get release agent')
    complete_task('get carbon and fiberglass')

    send_message(
      subject: 'RE: layup body carbon',
      body: "So, I've got a question: we're using two layers of carbon with a layer of fiberglass between them for the bottom body panel, but do we want to do the same for the top? It doesn't need to be as strong, and less fiberglass would be lighter, but will it crack?",
      user: @users[:tom],
      reply: true,
    )
    send_message(
      subject: 'RE: layup body carbon',
      body: "I think I can get in touch with Yan's friend who built the carbon kayak.  He might know!",
      user: @users[:alice],
      reply: true,
    )
    send_message(
      subject: 'RE: layup body carbon',
      body: "Hey all! This looks pretty neat. Lets see if I can help you out here...\nSo on the kayak, we use two layers of carbon plus some batting on the bottom, and carbon/glass on the sides. Looking at the drawings on your blog, it seems like the top of the bodywork has a pretty wide unsupported area. In that case, I'd go for the carbon/glass, even though it's a little heavier. You could also use single layers of carbon and back it with some rod or some aluminum to reduce flexing and make it less likely to crack.\nGood luck!\nAndy",
      user: nil,
      from: '"Andy Lee Issacson" <andy@example.com>',
      reply: true,
    )
    send_message(
      subject: 'RE: layup body carbon',
      body: "Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass like you suggested, since we're under weight on the wheels anyway.",
      user: @users[:tom],
      reply: true,
    )
    send_message(
      subject: 'RE: layup body carbon',
      body: "This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of them before they went in. Bethany got epoxy everywhere! It was pretty funny.",
      user: @users[:tom],
      reply: true,
    )

    binding.pry

  rescue Object => e
    binding.pry
    raise
  end

  def create_user name, email
    User.create!(email: email, name: name, password: 'password')
  end

  def invite_user name, email
    user = create_user(name, email)
    @project.project_memberships.create!(user: user)
    user
  end

  def send_message(attributes)
    subject = attributes[:subject].sub(/^re: /i, '')
    conversation = @project.conversations.find_or_create_by_subject(subject) or
      raise "cant get project for subject: #{attributes.inspect}"
    conversation.messages.create!(attributes)
  end

  def create_task(subject)
    conversation = @project.conversations.create!(subject: subject)
    Task.create!(conversation: conversation)
  end

  def add_doer_to_task user, subject
    task = @project.conversations.where(subject: subject).first.task
    task.doers << user
  end

  def complete_task subject
    task = @project.conversations.where(subject: subject).first.task
    task.done!
  end

    # # list of conversations
    # {
    #   'layup body carbon' => true,
    #   'install mirrors' => true,
    #   'trim body panels' => true,
    #   'make wooden form for carbon layup' => true,
    #   'mount body on frame' => true,
    #   'install body clips' => true,
    #   'How are we going to build the body?' => false,
    #   'get mirrors' => true,
    #   'get epoxy' => true,
    #   'get release agent' => true,
    #   'get carbon and fiberglass' => true,
    # }.each do |subject, it_is_a_task|
    #   conversation = raceteam.conversations.create!(subject: subject)
    #   next unless it_is_a_task
    #   conversation.task = Task.new
    #   conversation.task.save!
    # end

    # def generate_message_id
    #   'your-fantasy-message-id@example.com'
    # end

    # # list of messages in a single conversation
    # last_message = nil
    # conversation = raceteam.conversations.where(subject: 'layup body carbon').first

    # [
    #   {
    #     body: "Some stuff about how we have decided on a course of action for this body.\nSo, let's do some carbon layup!",
    #     user: users[:alice],
    #     reply: false
    #   },
    #   {
    #     body: "Totally!\nI'm thinking we can do this on our first January workday. I'll make sure we get the supplies in time",
    #     user: users[:tom],
    #     reply: true
    #   },
    #   {
    #     body: "I'm so there! Also, I think I can probably pick up some of those supplies from a friend, who was trying to make a kayak.",
    #     user: users[:yan],
    #     reply: true
    #   },
    #   {
    #     body: "So, I've got a question: we're using two layers of carbon with a layer of fiberglass between them for the bottom body panel, but do we want to do the same for the top? It doesn't need to be as strong, and less fiberglass would be lighter, but will it crack?",
    #     user: users[:tom],
    #     reply: true
    #   },
    #   {
    #     body: "I think I can get in touch with Yan's friend who built the carbon kayak.  He might know!",
    #     user: users[:alice],
    #     reply: true
    #   },
    #   {
    #     body: "Hey all! This looks pretty neat. Lets see if I can help you out here...\nSo on the kayak, we use two layers of carbon plus some batting on the bottom, and carbon/glass on the sides. Looking at the drawings on your blog, it seems like the top of the bodywork has a pretty wide unsupported area. In that case, I'd go for the carbon/glass, even though it's a little heavier. You could also use single layers of carbon and back it with some rod or some aluminum to reduce flexing and make it less likely to crack.\nGood luck!\nAndy",
    #     user: nil,
    #     from: '"Andy Lee Issacson" <andy@example.com>',
    #     reply: true
    #   },
    #   {
    #     body: "Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass like you suggested, since we're under weight on the wheels anyway.",
    #     user: users[:tom],
    #     reply: true
    #   },
    #   {
    #     body: "This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of them before they went in. Bethany got epoxy everywhere! It was pretty funny.",
    #     user: users[:tom],
    #     reply: true
    #   },

    # ].each do |message_hash|
    #   # TODO: populate children
    #   message = conversation.messages.create(message_hash.merge({
    #     subject: 'layup body carbon',
    #     parent_message: message_hash[:reply] ? last_message : nil,
    #     message_id_header: generate_message_id
    #   }))
    #   last_message = message
    # end
  # end

end.new.go!




