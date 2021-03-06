FixtureBuilder.build do

  as_an_admin do
    create_organization(
      name:          'UCSD Electric Racing',
      short_name:    'RaceTeam',
      description:   'Senior engineering electric race team!',
      trusted:       true,
      plan:          :paid,
      public_signup: true,
    )
    add_member 'Alice Neilson', 'alice@ucsd.example.com', true
  end

  as 'alice@ucsd.example.com' do
    add_domain 'raceteam.com'
    add_domain 'raceteam.ucsd.edu'
  end

  Time.zone = 'US/Pacific'
  Timecop.travel( Time.zone.local(2014,2,1).utc )
  Timecop.scale(3600)

  web_enable! 'alice@ucsd.example.com'
  as 'alice@ucsd.example.com' do
    set_avatar! 'alice.jpg'
    dismiss_welcome_modal!

    # Alice invites her organization mates
    add_member 'Tom Canver',       'tom@ucsd.example.com'
    add_member 'Yan Hzu',          'yan@ucsd.example.com'
    add_member 'Bethany Pattern',  'bethany@ucsd.example.com'
    add_member 'Bob Cauchois',     'bob@ucsd.example.com'
    add_member 'Jonathan Spray',   'jonathan@ucsd.example.com'
    add_member 'Nadya Leviticon',  'nadya@ucsd.example.com'
    add_member 'Ricky Bobby',      'ricky.bobby@ucsd.example.com'
    add_member 'Cal Naughton Jr.', 'cal.naughton@ucsd.example.com'

    add_member 'Lord Vader',       'darth@ucsd.example.com'
    remove_member 'darth@ucsd.example.com' # he's hard to work with.

    set_avatar! 'ricky.bobby.jpg', for: 'ricky.bobby@ucsd.example.com'

    # Add member from sfhealth, to have a member in two orgs
    add_member 'Lilith Sternin',  'lilith@sfhealth.example.com'

    # Alice sends a welcome email
    @welcome_message = create_conversation(
      subject: 'Welcome to our Threadable organization!',
      text: 'Hey all! I think we should try this way to organize our conversation and work for the car. Thanks for joining up!',
    )
  end

  web_enable! 'ricky.bobby@ucsd.example.com'
  as 'ricky.bobby@ucsd.example.com' do
    set_group_to_summary 'raceteam'
  end

  web_enable! 'tom@ucsd.example.com'
  as 'tom@ucsd.example.com' do
    set_avatar! 'tom.jpg'
    dismiss_welcome_modal!
  end

  web_enable! 'yan@ucsd.example.com'
  as 'yan@ucsd.example.com' do
    set_avatar! 'yan.jpg'
    add_email_address! 'yan@yansterdam.io'
    confirm_email_address! 'yan@yansterdam.io'
    dismiss_welcome_modal!
  end

  web_enable! 'bethany@ucsd.example.com'
  as 'bethany@ucsd.example.com' do
    set_avatar! 'bethany.jpg'
    dismiss_welcome_modal!
  end

  web_enable! 'bob@ucsd.example.com'
  as 'bob@ucsd.example.com' do
    set_avatar! 'bob.jpg'
    add_email_address! 'bob.cauchois@example.com'
    dismiss_welcome_modal!
  end

  as 'jonathan@ucsd.example.com' do
    unsubscribe_from_organization_email!
  end

  web_enable! 'cal.naughton@ucsd.example.com'
  as 'cal.naughton@ucsd.example.com' do
    set_avatar! 'cal.naughton.jpg'
    remove_member_from_group 'raceteam', 'cal.naughton@ucsd.example.com'
    dismiss_welcome_modal!
  end

  # create some groups and put people in them
  as 'alice@ucsd.example.com' do
    @electronics_group = create_group name: 'Electronics', description: 'Soldering and wires and stuff!', color: '#964bf8', auto_join: false
    add_member_to_group 'electronics', 'tom@ucsd.example.com'
    add_member_to_group 'electronics', 'bethany@ucsd.example.com'

    @fundraising_group = create_group name: 'Fundraising', description: 'Cache Monet', color: '#5a9de1', auto_join: false
    add_member_to_group 'fundraising', 'alice@ucsd.example.com'
    add_member_to_group 'fundraising', 'bob@ucsd.example.com'
    add_member_to_group 'fundraising', 'nadya@ucsd.example.com'

    @graphic_design_group = create_group name: 'Graphic Design', description: 'I like helvetica', color: '#f2ad40', auto_join: true

    @press_group = create_group name: 'Press', color: '#e67e22', description: 'How to talk to the news media', auto_join: false, alias_email_address: 'Press Enquiries <press@ucsd.example.com>'
    add_member_to_group 'press', 'tom@ucsd.example.com'
    add_member_to_group 'press', 'nadya@ucsd.example.com'

    @leaders_group = create_group name: 'Leaders', color: '#e67e22', description: 'Secret Leadership Cabal', private: true, auto_join: false
    add_member_to_group 'leaders', 'alice@ucsd.example.com'
    add_member_to_group 'leaders', 'tom@ucsd.example.com'

    @primary_group = organization.groups.find_by_slug!('raceteam')
  end

  as 'bob@ucsd.example.com' do
    set_group_to_summary('fundraising')
  end

  # Bethany replies to the welcome email
  as 'bethany@ucsd.example.com' do
    reply_to @welcome_message, text: 'Yay! You go Alice. This tool looks radder than an 8-legged panda.'
    mute_conversation @welcome_message.conversation
  end

  Timecop.travel( Time.zone.local(2014,2,2).utc )
  Timecop.scale(3600)

  as 'tom@ucsd.example.com' do
    create_conversation(
      subject: 'How are we going to build the body?',
      text: (
        %(I'm not 100% clear on the right way to go for this, but we should figure out if we're going to )+
        %(make the body out of carbon or buy a giant boat and cut it up or whatever.)
      )
    )

    @parts_for_the_motor_controller = create_conversation(
      subject: 'Parts for the motor controller',
      text:    %(Where should we get the SCRs for the motor controller? My usual supplier is out of them.),
      groups:  [@electronics_group],
    )

    @parts_for_the_drive_train = create_conversation(
      subject: 'Parts for the drive train',
      text:    %(Where are all the parts for the drive train? I left them at the shop last night),
      groups:  [@electronics_group],
    )

    @drive_trains_are_expensive = create_conversation(
      subject: 'Drive trains are expensive!',
      text:    %(We should get some nice renders of the motor and transmission for our fundraising video.),
      groups:  [@electronics_group, @fundraising_group],
    )

    @recruiting = create_conversation(
      subject: 'Recruiting?',
      text:    %(We need to find a CNC machinist and a painter),
      groups:  [@leaders_group],
    )

    @budget_worknight = create_conversation(
      subject: 'Budget worknight',
      text:    %(Let's have a budget worknight on wednesday),
      groups:  [@leaders_group, @fundraising_group],
    )

    conversation_of_cash = create_conversation(
      subject:        'How are we paying for the motor controller?',
      body_plain:     %(We need cash, baby. And this has quoted text.),
      stripped_plain: %(We need cash, baby.),
      groups:         [@electronics_group, @fundraising_group]
    )
    remove_conversation_from_group(conversation_of_cash, @electronics_group)

    reply_to(conversation_of_cash,
      body_plain:     "Totally!\nI'm thinking we can do this on our first January workday. I'll make sure we get the supplies in time\n> quoted text\n> more quoted text",
      stripped_plain: "Totally!\nI'm thinking we can do this on our first January workday. I'll make sure we get the supplies in time",
      attachments:    [
        attachment('some.gif', 'image/gif'),
        attachment('some.jpg', 'image/jpeg'),
        attachment('some.txt', 'text/plain', false),
      ],
    )

    @omg_i_am_so_drunk = create_conversation(
      subject: 'OMG I am so drunk!',
      text:    %(Hey guys. This party is awesome! Woo!),
      groups:  [@electronics_group],
    )

    reply_to(@omg_i_am_so_drunk,
      body_plain:     "Oops. Sorry about that. Deleting this one now.",
      stripped_plain: "Oops. Sorry about that. Deleting this one now.",
    )
    trash_conversation(@omg_i_am_so_drunk)
  end

  as 'alice@ucsd.example.com' do
    @layup_body_carbon_task = create_task 'layup body carbon'
    create_task 'install mirrors'
    @trim_body_panels_task = create_task 'trim body panels'
    create_task 'make wooden form for carbon layup'

    @initial_layup_body_carbon_message = create_message( @layup_body_carbon_task,
      text: "Some stuff about how we have decided on a course of action for this body.\nSo, let's do some carbon layup!",
    )
  end

  as 'tom@ucsd.example.com' do
    reply_to(@initial_layup_body_carbon_message,
      text: "Totally!\nI'm thinking we can do this on our first January workday. I'll make sure we get the supplies in time",
    )
    add_doer_to_task @layup_body_carbon_task, 'tom@ucsd.example.com'
  end


  as 'alice@ucsd.example.com' do
    @get_epoxy_task                 = create_task 'get epoxy'
    @get_release_agent_task         = create_task 'get release agent'
    @get_carbon_and_fiberglass_task = create_task 'get carbon and fiberglass'
    @get_a_new_soldering_iron       = create_task 'get a new soldering iron'
    @get_some_4_gauge_wire          = create_task 'get some 4 gauge wire'

    add_conversation_to_group       @get_a_new_soldering_iron, @electronics_group
    add_conversation_to_group       @get_some_4_gauge_wire, @electronics_group
    add_conversation_to_group       @get_some_4_gauge_wire, @fundraising_group

    remove_conversation_from_group  @get_a_new_soldering_iron, @primary_group
    remove_conversation_from_group  @get_some_4_gauge_wire, @primary_group
  end

  as 'yan@ucsd.example.com' do
    reply_to(@initial_layup_body_carbon_message,
      text: "I'm so there! Also, I think I can probably pick up some of those supplies from a friend, who was trying to make a kayak.",
    )
    add_doer_to_task @layup_body_carbon_task, 'yan@ucsd.example.com'

    create_message( @get_a_new_soldering_iron,
      text: "Our soldering iron sucks. It glows red hot sometimes.",
    )
  end


  as 'tom@ucsd.example.com' do
    add_doer_to_task @get_epoxy_task, 'tom@ucsd.example.com'
    add_doer_to_task @get_release_agent_task, 'tom@ucsd.example.com'
    add_doer_to_task @get_release_agent_task, 'yan@ucsd.example.com'
    add_doer_to_task @get_carbon_and_fiberglass_task, 'tom@ucsd.example.com'
    add_doer_to_task @trim_body_panels_task, 'tom@ucsd.example.com'
    add_doer_to_task @get_a_new_soldering_iron, 'bethany@ucsd.example.com'

    mark_task_as_done @get_epoxy_task
    mark_task_as_done @get_release_agent_task
    mark_task_as_done @get_carbon_and_fiberglass_task


    @last_layup_body_carbon_message = reply_to(@initial_layup_body_carbon_message,
      text: (
        %(So, I've got a question: we're using two layers of carbon with a layer of fiberglass )+
        %(between them for the bottom body panel, but do we want to do the same for the top? It )+
        %(doesn't need to be as strong, and less fiberglass would be lighter, but will it crack?)
      )
    )
  end

  as 'alice@ucsd.example.com' do
    @last_layup_body_carbon_message = reply_to(@last_layup_body_carbon_message,
      text: "I think I can get in touch with Yan's friend who built the carbon kayak. He might know!"
    )
  end

  # a message from someone without an account
  @layup_body_carbon_task.messages.create!(
    parent_message: @last_layup_body_carbon_message,
    from: '"Andy Lee Issacson" <andy@example.com>',
    text: (
      %(Hey all! This looks pretty neat. Lets see if I can help you out here...\n\n\n)+
      %(So on the kayak, we use two layers of carbon plus some batting on the bottom, )+
      %(and carbon/glass on the sides. Looking at the drawings on your blog, it seems )+
      %(like the top of the bodywork has a pretty wide unsupported area. In that case, )+
      %(I'd go for the carbon/glass, even though it's a little heavier. You could also )+
      %(use single layers of carbon and back it with some rod or some aluminum to )+
      %(reduce flexing and make it less likely to crack.\n\n\nGood luck!\n--\nAndy)
    )
  );

  as 'tom@ucsd.example.com' do
    @last_layup_body_carbon_message = reply_to(@last_layup_body_carbon_message,
      text: (
        %(Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass like you suggested, )+
        %(since we're under weight on the wheels anyway.)
      )
    )

    @last_layup_body_carbon_message = reply_to(@last_layup_body_carbon_message,
      body_plain: (
        %(This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting )+
        %(everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of )+
        %(them before they went in. Bethany got epoxy everywhere! It was pretty funny.\n\n Wow, thanks )+
        %(Andy! Super helpful. I think we'll just go for the carbon/glass\n like you suggested, since )+
        %(we're under weight on the wheels anyway.\n\n)+
        %(> Wow, thanks Andy! Super helpful. I think we'll\n)+
        %(> just go for the carbon/glass like you suggested,\n)+
        %(> since we're under weight on the wheels anyway.\n)
      ),
      stripped_plain: (
        %(This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting )+
        %(everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of )+
        %(them before they went in. Bethany got epoxy everywhere! It was pretty funny.\n\n Wow, thanks )+
        %(Andy! Super helpful. I think we'll just go for the carbon/glass\n like you suggested, since )+
        %(we're under weight on the wheels anyway.)
      ),
      body_html: (
        %(<p>)+
        %(This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting )+
        %(everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of )+
        %(them before they went in. Bethany got epoxy everywhere! It was pretty funny.\n\n Wow, thanks )+
        %(</p>)+
        %(<p>)+
        %(Andy! Super helpful. I think we'll just go for the carbon/glass\n like you suggested, since )+
        %(we're under weight on the wheels anyway.\n\n)+
        %(</p>)+
        %(<blockquote>)+
        %(Wow, thanks Andy! Super helpful. I think we'll\n)+
        %(just go for the carbon/glass like you suggested,\n)+
        %(since we're under weight on the wheels anyway.\n)+
        %(</blockquote>)
      ),
      stripped_html: (
        %(<p>)+
        %(This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting )+
        %(everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of )+
        %(them before they went in. Bethany got epoxy everywhere! It was pretty funny.\n\n Wow, thanks )+
        %(</p>)+
        %(<p>)+
        %(Andy! Super helpful. I think we'll just go for the carbon/glass\n like you suggested, since )+
        %(we're under weight on the wheels anyway.\n\n)+
        %(</p>)
      ),
    )

    mark_task_as_done @layup_body_carbon_task
  end


  as 'tom@ucsd.example.com' do
    create_conversation(
      to_header: %(#{organization.formatted_email_address}, somebody@else.io, alice@ucsd.example.com, Bethany Pattern <bethany@ucsd.example.com>),
      cc_header: %("Bob Cauchois" <bob@ucsd.example.com>, another@random-person.com),
      subject:   %(Who wants to pick up lunch?),
      text:      %(I like cheese. I think someone else likes cheese too.),
    )
    create_conversation(
      to_header: %(some@guy.com),
      cc_header: %(#{organization.formatted_email_address}, "Bob Cauchois" <bob@ucsd.example.com>, another@random-person.com),
      subject:   %(Who wants to pick up dinner?),
      text:      %(I like potatoes. I think someone else likes potatoes too.),
    )
    create_conversation(
      to_header: %(somebody@else.io, alice@ucsd.example.com, Bethany Pattern <bethany@ucsd.example.com>),
      cc_header: %("Bob Cauchois" <bob@ucsd.example.com>, another@random-person.com),
      # bcc_header: organization.formatted_email_address # <--- Let's assume the organization was BCC'd
      subject:   %(Who wants to pick up breakfast?),
      text:      %(I like foodz. I've been here all night!!!!!),
    )
  end


  as 'bethany@ucsd.example.com' do
    mute_conversation @layup_body_carbon_task
    mute_conversation @get_epoxy_task
    mute_conversation @get_release_agent_task
    mute_conversation @get_carbon_and_fiberglass_task
    mute_conversation @parts_for_the_drive_train
  end

  as 'alice@ucsd.example.com' do
    @inventory_led_supplies_task = create_task 'inventory led supplies'

    @initial_inventory_led_supplies_message = create_message( @inventory_led_supplies_task,
      text: "Cars need lights, so lets get a sense of our led situation!",
    )
    add_conversation_to_group       @inventory_led_supplies_task, @electronics_group
    add_conversation_to_group       @inventory_led_supplies_task, @graphic_design_group
    add_conversation_to_group       @inventory_led_supplies_task, @fundraising_group
  end

  Timecop.return
end
