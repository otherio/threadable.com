FixtureBuilder.build do

  # Alice signs up
  sign_up 'Alice Neilson', 'alice@ucsd.covered.io'

  as 'alice@ucsd.covered.io' do
    confirm_account!
    set_avatar! 'alice.jpg'

    create_project(
      name: 'UCSD Electric Racing',
      short_name: 'RaceTeam',
      description: 'Senior engineering electric race team!',
    )

    # Alice invites her project mates
    add_member 'Tom Canver',      'tom@ucsd.covered.io'
    add_member 'Yan Hzu',         'yan@ucsd.covered.io'
    add_member 'Bethany Pattern', 'bethany@ucsd.covered.io'
    add_member 'Bob Cauchois',    'bob@ucsd.covered.io'
    add_member 'Jonathan Spray',  'jonathan@ucsd.covered.io'

    # Alice sends a welcome email
    @welcome_message = create_conversation(
      subject: 'Welcome to our new Covered project!',
      text: 'Hey all! I think we should try this way to organize our conversation and work for the car. Thanks for joining up!',
    )
  end

  as 'tom@ucsd.covered.io' do
    confirm_account!
    web_enable!
    set_avatar! 'tom.jpg'
  end

  as 'yan@ucsd.covered.io' do
    confirm_account!
    web_enable!
    set_avatar! 'yan.jpg'
    add_email_address! 'yan@yansterdam.io'
  end

  as 'bethany@ucsd.covered.io' do
    confirm_account!
    set_avatar! 'bethany.jpg'
  end

  as 'bob@ucsd.covered.io' do
    confirm_account!
    web_enable!
    set_avatar! 'bob.jpg'
  end

  as 'jonathan@ucsd.covered.io' do
    unsubscribe_from_project_email!
  end


  # Bethany replies to the welcome email
  as 'bethany@ucsd.covered.io' do
    reply_to @welcome_message, text: 'Yay! You go Alice. This tool looks radder than an 8-legged panda.'
  end

  as 'tom@ucsd.covered.io' do
    create_conversation(
      subject: 'How are we going to build the body?',
      text: (
        %(I'm not 100% clear on the right way to go for this, but we should figure out if we're going to )+
        %(make the body out of carbon or buy a giant boat and cut it up or whatever.)
      )
    )
  end



  as 'alice@ucsd.covered.io' do
    @layup_body_carbon_task = create_task 'layup body carbon'
    create_task 'install mirrors'
    @trim_body_panels_task = create_task 'trim body panels'
    create_task 'make wooden form for carbon layup'

    @initial_layup_body_carbon_message = create_message( @layup_body_carbon_task,
      text: "Some stuff about how we have decided on a course of action for this body.\nSo, let's do some carbon layup!",
    )
  end

  as 'tom@ucsd.covered.io' do
    reply_to(@initial_layup_body_carbon_message,
      text: "Totally!\nI'm thinking we can do this on our first January workday. I'll make sure we get the supplies in time",
    )
    add_doer_to_task @layup_body_carbon_task, 'tom@ucsd.covered.io'
  end


  as 'alice@ucsd.covered.io' do
    @get_epoxy_task                 = create_task 'get epoxy'
    @get_release_agent_task         = create_task 'get release agent'
    @get_carbon_and_fiberglass_task = create_task 'get carbon and fiberglass'
  end

  as 'yan@ucsd.covered.io' do
    reply_to(@initial_layup_body_carbon_message,
      text: "I'm so there! Also, I think I can probably pick up some of those supplies from a friend, who was trying to make a kayak.",
    )
    add_doer_to_task @layup_body_carbon_task, 'yan@ucsd.covered.io'
  end


  as 'tom@ucsd.covered.io' do
    add_doer_to_task @get_epoxy_task, 'tom@ucsd.covered.io'
    add_doer_to_task @get_release_agent_task, 'tom@ucsd.covered.io'
    add_doer_to_task @get_release_agent_task, 'yan@ucsd.covered.io'
    add_doer_to_task @get_carbon_and_fiberglass_task, 'tom@ucsd.covered.io'
    add_doer_to_task @trim_body_panels_task, 'tom@ucsd.covered.io'

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

  as 'alice@ucsd.covered.io' do
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

  as 'tom@ucsd.covered.io' do
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

end