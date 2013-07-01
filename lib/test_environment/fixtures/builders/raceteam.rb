TestEnvironment::FixtureBuilder.new do

  # Alice signs up
  create_user('Alice Neilson', 'alice@ucsd.covered.io')

  # Alice creates a project
  @project = Project.create!(
    name: 'UCSD Electric Racing',
    description: 'Senior engineering electric race team!',
  )
  project.members << user('Alice Neilson')

  # Alice invites her project mates
  invite_user 'Tom Canver',      'tom@ucsd.covered.io'
  invite_user 'Yan Hzu',         'yan@ucsd.covered.io'
  invite_user 'Bethany Pattern', 'bethany@ucsd.covered.io'
  invite_user 'Bob Cauchois',    'bob@ucsd.covered.io'
  invite_user 'Jonathan Spray',  'jonathan@ucsd.covered.io'

  # Alice's project mates all accept their invites
  accept_invite 'Tom Canver'
  accept_invite 'Yan Hzu'
  accept_invite 'Bethany Pattern'
  accept_invite 'Bob Cauchois'
  accept_invite 'Jonathan Spray'

  # Jonathan hates email
  unsubscribe_from_project_email 'Jonathan Spray'

  # each user sets their avatar via magic!
  set_avatar 'alice@ucsd.covered.io',   'alice.jpg'
  set_avatar 'tom@ucsd.covered.io',     'tom.jpg'
  set_avatar 'bob@ucsd.covered.io',     'bob.jpg'
  set_avatar 'yan@ucsd.covered.io',     'yan.jpg'
  set_avatar 'bethany@ucsd.covered.io', 'bethany.jpg'

  # Alice sends a welcome email
  send_message(
    user: 'Alice Neilson',
    reply: false,
    subject: 'Welcome to our new Covered project!',
    stripped_plain: 'Hey all! I think we should try this way to organize our conversation and work for the car. Thanks for joining up!',
    body_plain: 'Hey all! I think we should try this way to organize our conversation and work for the car. Thanks for joining up!'
  )

  # Bethany replies to the welcome email
  send_message(
    user: 'Bethany Pattern',
    reply: true,
    subject: 'RE: Welcome to our new Covered project!',
    stripped_plain: 'Yay! You go Alice. This tool looks radder than an 8-legged panda.',
    body_plain: 'Yay! You go Alice. This tool looks radder than an 8-legged panda.',
  )

  # Tom has a question
  send_message(
    user: 'Tom Canver',
    reply: false,
    subject: 'How are we going to build the body?',
    stripped_plain: "I'm not 100% clear on the right way to go for this, but we should figure out if we're going to make the body out of carbon or buy a giant boat and cut it up or whatever.",
    body_plain: "I'm not 100% clear on the right way to go for this, but we should figure out if we're going to make the body out of carbon or buy a giant boat and cut it up or whatever.",
  )


  # Alice starts making some tasks
  create_task 'Alice Neilson', 'layup body carbon'
  create_task 'Alice Neilson', 'install mirrors'
  create_task 'Alice Neilson', 'trim body panels'
  create_task 'Alice Neilson', 'make wooden form for carbon layup'


  send_message(
    subject: 'layup body carbon',
    stripped_plain: "Some stuff about how we have decided on a course of action for this body.\nSo, let's do some carbon layup!",
    body_plain: "Some stuff about how we have decided on a course of action for this body.\nSo, let's do some carbon layup!",
    user: 'Alice Neilson',
    reply: false,
  )

  send_message(
    subject: 'RE: layup body carbon',
    stripped_plain: "Totally!\nI'm thinking we can do this on our first January workday. I'll make sure we get the supplies in time",
    body_plain: "Totally!\nI'm thinking we can do this on our first January workday. I'll make sure we get the supplies in time",
    user: 'Tom Canver',
    reply: true,
  )
  add_doer_to_task 'Tom Canver', 'layup body carbon'

  create_task 'Alice Neilson', 'get epoxy'
  create_task 'Alice Neilson', 'get release agent'
  create_task 'Alice Neilson', 'get carbon and fiberglass'

  send_message(
    subject: 'RE: layup body carbon',
    stripped_plain: "I'm so there! Also, I think I can probably pick up some of those supplies from a friend, who was trying to make a kayak.",
    body_plain: "I'm so there! Also, I think I can probably pick up some of those supplies from a friend, who was trying to make a kayak.",
    user: 'Yan Hzu',
    reply: true,
  )
  add_doer_to_task 'Yan Hzu', 'layup body carbon'

  add_doer_to_task 'Tom Canver', 'get epoxy'
  add_doer_to_task 'Tom Canver', 'get release agent'
  add_doer_to_task 'Yan Hzu',    'get release agent'
  add_doer_to_task 'Tom Canver', 'get carbon and fiberglass'
  add_doer_to_task 'Tom Canver', 'trim body panels'

  complete_task 'Tom Canver', 'get epoxy'
  complete_task 'Tom Canver', 'get release agent'
  complete_task 'Tom Canver', 'get carbon and fiberglass'

  send_message(
    subject: 'RE: layup body carbon',
    stripped_plain: "So, I've got a question: we're using two layers of carbon with a layer of fiberglass between them for the bottom body panel, but do we want to do the same for the top? It doesn't need to be as strong, and less fiberglass would be lighter, but will it crack?",
    body_plain: "So, I've got a question: we're using two layers of carbon with a layer of fiberglass between them for the bottom body panel, but do we want to do the same for the top? It doesn't need to be as strong, and less fiberglass would be lighter, but will it crack?",
    user: 'Tom Canver',
    reply: true,
  )

  send_message(
    subject: 'RE: layup body carbon',
    stripped_plain: "I think I can get in touch with Yan's friend who built the carbon kayak.  He might know!",
    body_plain: "I think I can get in touch with Yan's friend who built the carbon kayak.  He might know!",
    user: 'Alice Neilson',
    reply: true,
  )

  send_message(
    subject: 'RE: layup body carbon',
    body_plain: "Hey all! This looks pretty neat. Lets see if I can help you out here...\nSo on the kayak, we use two layers of carbon plus some batting on the bottom, and carbon/glass on the sides. Looking at the drawings on your blog, it seems like the top of the bodywork has a pretty wide unsupported area. In that case, I'd go for the carbon/glass, even though it's a little heavier. You could also use single layers of carbon and back it with some rod or some aluminum to reduce flexing and make it less likely to crack.\nGood luck!\nAndy",
    stripped_plain: "Hey all! This looks pretty neat. Lets see if I can help you out here...\nSo on the kayak, we use two layers of carbon plus some batting on the bottom, and carbon/glass on the sides. Looking at the drawings on your blog, it seems like the top of the bodywork has a pretty wide unsupported area. In that case, I'd go for the carbon/glass, even though it's a little heavier. You could also use single layers of carbon and back it with some rod or some aluminum to reduce flexing and make it less likely to crack.\nGood luck!\nAndy",
    user: nil,
    from: '"Andy Lee Issacson" <andy@example.com>',
    reply: true,
  )

  message = send_message(
    subject: 'RE: layup body carbon',
    stripped_plain: "Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass like you suggested, since we're under weight on the wheels anyway.",
    body_plain: "Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass like you suggested, since we're under weight on the wheels anyway.",
    user: 'Tom Canver',
    reply: true,
  )

  send_message(
    parent_message: message,
    subject: 'RE: layup body carbon',
    body_plain: "This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of them before they went in. Bethany got epoxy everywhere! It was pretty funny.\n\n> Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass\n> like you suggested, since we're under weight on the wheels anyway.",
    stripped_plain: "This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of them before they went in. Bethany got epoxy everywhere! It was pretty funny.",
    user: 'Tom Canver',
    reply: true,
  )

  complete_task 'Tom Canver', 'layup body carbon'

end
