FixtureBuilder.build do
  Timecop.travel(Date.today - 8.hours)
  Timecop.scale(8600)

  as_an_admin do
    create_organization(
      name: 'SF Health Center',
      short_name: 'SFHealth',
      description: 'San Francisco Health Center',
    )
    add_member 'Amy Wong', 'amywong.phd@gmail.com'
  end

  web_enable! 'amywong.phd@gmail.com'
  as 'amywong.phd@gmail.com' do
    set_avatar! 'amy.jpg'

    # Amy invites her organization mates
    add_member 'Sandeep Prakash', 'sfmedstudent@gmail.com'
    add_member 'Lilith Sternin',  'lilith@sfhealth.example.com'
    add_member 'Anil Kapoor',     'anil@sfhealth.example.com'
    add_member 'Trapper John',    'trapper@sfhealth.example.com'
    add_member 'Marcus Welby',    'marcus@sfhealth.example.com'
    add_member 'Michaela Quinn',  'mquinn@sfhealth.example.com'
    add_member 'B.J. Hunnicutt',  'bj@sfhealth.example.com'
    add_member 'Stephen Maturin', 'smaturin@sfhealth.example.com'
    add_member 'Lisa Cuddy',      'lcuddy@sfhealth.example.com'
    add_member 'Gregory House',   'house@sfhealth.example.com'
    add_member 'Ritsuko Akagi',   'ritsuko@sfhealth.example.com'
    add_member 'Yuri Zhivago',    'yuriz@sfhealth.example.com'
    add_member 'Hans Zarkov',     'zarkov@sfhealth.example.com'
    add_member 'Peter Venkman',   'ecto@sfhealth.example.com'

    @welcome_message = create_conversation(
      subject: 'Welcome to our new Covered organization!',
      text:    'Hey all! I think we should try this way to organize our conversation and work. Thanks for joining up!',
    )

  end


  # Amy's organization mates all accept their invites
  web_enable! 'sfmedstudent@gmail.com'
  as 'sfmedstudent@gmail.com' do
    set_avatar! 'sandeep.jpg'
  end

  web_enable! 'lilith@sfhealth.example.com'
  as 'lilith@sfhealth.example.com' do
    set_avatar! 'lilith.jpg'
  end

  web_enable! 'anil@sfhealth.example.com'
  as 'anil@sfhealth.example.com' do
    set_avatar! 'anil.jpg'
  end

  web_enable! 'trapper@sfhealth.example.com'
  as 'trapper@sfhealth.example.com' do
    set_avatar! 'trapper.jpg'
  end

  web_enable! 'marcus@sfhealth.example.com'
  as 'marcus@sfhealth.example.com' do
    set_avatar! 'marcus.jpg'
  end

  web_enable! 'mquinn@sfhealth.example.com'
  as 'mquinn@sfhealth.example.com' do
    set_avatar! 'mquinn.jpg'
  end

  web_enable! 'bj@sfhealth.example.com'
  as 'bj@sfhealth.example.com' do
    set_avatar! 'bj.jpg'
  end

  web_enable! 'smaturin@sfhealth.example.com'
  as 'smaturin@sfhealth.example.com' do
    set_avatar! 'stephen.jpg'
  end

  web_enable! 'lcuddy@sfhealth.example.com'
  as 'lcuddy@sfhealth.example.com' do
    set_avatar! 'lisa.jpg'
  end

  web_enable! 'house@sfhealth.example.com'
  as 'house@sfhealth.example.com' do
    set_avatar! 'house.jpg'
  end

  web_enable! 'ritsuko@sfhealth.example.com'
  as 'ritsuko@sfhealth.example.com' do
    set_avatar! 'ritsuko.jpg'
  end

  web_enable! 'yuriz@sfhealth.example.com'
  as 'yuriz@sfhealth.example.com' do
    set_avatar! 'yuri.jpg'
  end

  web_enable! 'zarkov@sfhealth.example.com'
  as 'zarkov@sfhealth.example.com' do
    set_avatar! 'zarkov.gif'
  end

  web_enable! 'ecto@sfhealth.example.com'
  as 'ecto@sfhealth.example.com' do
    set_avatar! 'venkman.jpg'
  end

  # create some groups and put people in them
  as 'amywong.phd@gmail.com' do
    @social_group = create_group 'Social', '#964bf8'
    add_member_to_group 'social', 'lilith@sfhealth.example.com'
    add_member_to_group 'social', 'anil@sfhealth.example.com'
    add_member_to_group 'social', 'yuriz@sfhealth.example.com'
    add_member_to_group 'social', 'ritsuko@sfhealth.example.com'
    add_member_to_group 'social', 'amywong.phd@gmail.com'
    add_member_to_group 'social', 'bj@sfhealth.example.com'

    @triage_group = create_group 'Triage', '#5a9de1'
    add_member_to_group 'triage', 'amywong.phd@gmail.com'
    add_member_to_group 'triage', 'anil@sfhealth.example.com'
    add_member_to_group 'triage', 'sfmedstudent@gmail.com'
    add_member_to_group 'triage', 'marcus@sfhealth.example.com'
    add_member_to_group 'triage', 'trapper@sfhealth.example.com'
    add_member_to_group 'triage', 'mquinn@sfhealth.example.com'
    add_member_to_group 'triage', 'house@sfhealth.example.com'
    add_member_to_group 'triage', 'yuriz@sfhealth.example.com'
    add_member_to_group 'triage', 'smaturin@sfhealth.example.com'
    add_member_to_group 'triage', 'bj@sfhealth.example.com'
    add_member_to_group 'triage', 'lcuddy@sfhealth.example.com'

    @anesthiology_group = create_group 'Anesthiology', '#f2ad40'
    add_member_to_group 'anesthiology', 'ecto@sfhealth.example.com'
    add_member_to_group 'anesthiology', 'mquinn@sfhealth.example.com'
    add_member_to_group 'anesthiology', 'house@sfhealth.example.com'
    add_member_to_group 'anesthiology', 'yuriz@sfhealth.example.com'
    add_member_to_group 'anesthiology', 'smaturin@sfhealth.example.com'
    add_member_to_group 'anesthiology', 'bj@sfhealth.example.com'

    @cardiology_group = create_group 'Cardiology', '#d94876'
    add_member_to_group 'cardiology', 'ecto@sfhealth.example.com'
    add_member_to_group 'cardiology', 'smaturin@sfhealth.example.com'
    add_member_to_group 'cardiology', 'bj@sfhealth.example.com'
    add_member_to_group 'cardiology', 'ritsuko@sfhealth.example.com'
    add_member_to_group 'cardiology', 'zarkov@sfhealth.example.com'
    add_member_to_group 'cardiology', 'lcuddy@sfhealth.example.com'
  end

  # Lisa replies to the welcome email
  as 'lcuddy@sfhealth.example.com' do
    reply_to @welcome_message, {
      text: 'Yay! You go Amy. This tool looks radder than an 8-legged panda.',
    }
  end

  as 'ecto@sfhealth.example.com' do
    create_conversation(
      subject: 'New hire orientation next wednesday',
      text: (
        %(This is a reminder for all new hires that the orientation meeting is next wednesday at 10am in room ) +
        %(2202. In the meantime, I encourage you to to review the SF Health employee policies online here: ) +
        %(https://covered.sfhealth.com/hr/employee-policies/ and please feel free to ask me if you have any questions.)
      ),
      groups:  [@social_group],
    )
  end

  as 'lilith@sfhealth.example.com' do
    @free_calendars_message = create_conversation(
      subject: 'Free calendars & pen sets in the 2nd floor lunch room',
      text: (
        %(The rep for Replexafil dropped off some 2014 Replexafil calendars and pen sets for us. They're in the )+
        %(2nd floor lunch room if anyone wants one. Help yourself.)
      ),
      groups:  [@social_group],
    )
  end

  as 'ritsuko@sfhealth.example.com' do
    reply_to @free_calendars_message, {
      text: "Does anyone here still use paper calendars?",
    }
  end

  as 'smaturin@sfhealth.example.com' do
    reply_to @free_calendars_message, {
      text: (
        %(That would be me. Haven't quite gotten the hang of my iPad yet. I'm afraid I'll still be using traditional )+
        %(scheduling tools for some time to come. Indeed, if anyone wishes to contact me, I'd encourage you to do so )+
        %(in person, as I hardly even have time to check my electronic mail these days. My sincere apologies.)
      )
    }
  end

  as 'lilith@sfhealth.example.com' do
    reply_to @free_calendars_message, {
      text: "Noted, Doc. I'll grab one of the calendars for you at lunch, and drop it by your office later.",
    }
  end

  as 'ecto@sfhealth.example.com' do
    @conference_message = create_conversation(
      subject: "2014 International Diagnostics Conference -- Who's going?",
      text: "Registration for the 2013 IDCC is coming up. Is anyone planning on attending?",
    )
  end

  as 'anil@sfhealth.example.com' do
    @where_is_conference_message = reply_to @conference_message, {
      text: "Where is it being held this year?",
    }
  end

  as 'ecto@sfhealth.example.com' do
    reply_to @where_is_conference_message, {
      text: "In Seattle. Here's the conference website: http://www.idcconference.com",
    }
  end


  as 'amywong.phd@gmail.com' do
    @call_x_ray_machine_maintenance_company_task = create_task 'Call X-ray machine maintenance company'
  end

  as 'lilith@sfhealth.example.com' do
    @review_our_intake_policies_task = create_task 'Review our intake policies'
  end

  as 'bj@sfhealth.example.com' do
    create_task 'Update EMS forms to new version'
  end

  as 'anil@sfhealth.example.com' do
    create_task 'Replace the power cord for vitals monitor #4'
  end

  as 'lilith@sfhealth.example.com' do
    create_task 'New triage desk vitals monitor', [@triage_group]  #triage
  end

  as 'amywong.phd@gmail.com' do
    create_task 'Order more glucose monitoring supplies'
  end

  as 'lilith@sfhealth.example.com' do
    create_task 'Write current EMS practice review', [@triage_group]  #triage
  end

  as 'lilith@sfhealth.example.com' do
    @print_new_info_signs_for_the_front_desk_task = create_task 'Print new info signs for the front desk'
  end

  as 'anil@sfhealth.example.com' do
    create_task 'Review literature on DVT prevention'
  end

  as 'anil@sfhealth.example.com' do
    @check_in_with_iv_supplies_vendor_task = create_task 'Check in with IV supplies vendor'
  end

  as 'amywong.phd@gmail.com' do
    create_task 'Revise PA paging procedures'
  end

  as 'bj@sfhealth.example.com' do
    create_task 'Review triage ECG procedures', [@triage_group]  #triage
  end

  as 'anil@sfhealth.example.com' do
    create_task 'Review standing orders for ASA and CP', [@triage_group, @anesthiology_group]  #triage
  end

  as 'amywong.phd@gmail.com' do
    create_task 'Review shift-change procedures'
  end

  as 'yuriz@sfhealth.example.com' do
    create_task 'Present our new central line system to the department'
  end

  as 'ecto@sfhealth.example.com' do
    @set_up_conference_room_for_orientation_task = create_task 'Set up conference room for orientation', [@social_group]
  end

  as 'amywong.phd@gmail.com' do
    create_task 'Write new intake form', [@triage_group]  #triage
  end

  as 'lilith@sfhealth.example.com' do
    @initial_iv_supplies_message = create_message(@check_in_with_iv_supplies_vendor_task,
      text: "So I think we're at a point where it makes sense to reach out to our...",
    )
    add_doer_to_task @check_in_with_iv_supplies_vendor_task, 'lilith@sfhealth.example.com'
    add_conversation_to_group(@initial_iv_supplies_message, @triage_group)
    add_conversation_to_group(@initial_iv_supplies_message, @anesthiology_group)
    @pick_up_bagels_for_orientation_task = create_task 'Pick up bagels for orientation', [@social_group]
    @drive_me_home_message = create_conversation(
      subject: 'Can anyone drive me home tonight?',
      groups: [@social_group],
      text: "So, my car just died. I took the bus in today, but it really sucked. Can anyone give me a lift home?"
    )
    reply_to(@drive_me_home_message, text: "Yuri's going to give me a ride! Thanks all!")
    reply_to(@drive_me_home_message, text: "Wow, you people are generous! Thanks for all the offers for help and good mechanics!\n\nLilith")
  end

  as 'amywong.phd@gmail.com' do
    create_task 'Pick up decorations for the halloween party'
  end

  as 'amywong.phd@gmail.com' do
    create_task 'Compare waiting times to acuity', [@triage_group]  #triage
  end

  as 'bj@sfhealth.example.com' do
    create_task 'Schedule a triage retrospective', [@triage_group]  #triage
  end

  as 'anil@sfhealth.example.com' do
    create_task 'Meet with SJ clinic about trauma classification', [@triage_group, @cardiology_group]  #triage
    reply_to(@initial_iv_supplies_message,
      text: (
        %(Absolutely! Pikachu ipsum dolor sit amet exeggutor sint doduo meowth. Vaporeon hypno occaecat consectetur )+
        %(aliquip. Culpa ex magna caterpie. Cupidatat incidunt ea tangela, do porygon pariatur venonat grimer voluptate )+
        %(jolteon raticate id Mr. Mime elit.\n\nEsse ut slowbro poliwrath, weepinbell eiusmod polywhirl charmander enim)+
        %(nidorina tempor.\n\nAnil)
      )
    )
  end

  as 'amywong.phd@gmail.com' do
    create_task 'Summarize triage review findings for board', [@triage_group]  #triage
    reply_to(@initial_iv_supplies_message,
      text: (
        %(I contacted them, and they'll be sending over supplies next week. I'm calling this done.\n\nIf we don't receive)+
        %(new IV supplies in the next two weeks, maybe reopen this.\n\n~Amy)
      )
    )
    mark_task_as_done @check_in_with_iv_supplies_vendor_task
  end


  as 'amywong.phd@gmail.com' do
    @xray_message = create_message(@call_x_ray_machine_maintenance_company_task, text:  "Lorem ipsum dolor sit amet")
  end

  as 'anil@sfhealth.example.com' do
    reply_to @xray_message, text: "Lorem ipsum dolor sit amet"
  end

  as 'lilith@sfhealth.example.com' do
    reply_to @xray_message, text: "Lorem ipsum dolor sit amet"
  end

  as 'anil@sfhealth.example.com' do
    reply_to @xray_message, text: "Lorem ipsum dolor sit amet"
  end

  as 'lilith@sfhealth.example.com' do
    add_doer_to_task @review_our_intake_policies_task, 'lilith@sfhealth.example.com'
    mark_task_as_done @review_our_intake_policies_task
    mark_task_as_done @call_x_ray_machine_maintenance_company_task
    mark_task_as_done @print_new_info_signs_for_the_front_desk_task
    mark_task_as_done @pick_up_bagels_for_orientation_task
    mark_task_as_done @set_up_conference_room_for_orientation_task
  end


  as 'anil@sfhealth.example.com' do
    create_conversation(
      subject: 'Staff halloween party!',
      text: 'Lorem upsum dolor sit amet',
      groups:  [@social_group],
    )
  end


  # Demo thread.  Put this at the end so it shows up near the top of the list

  as 'yuriz@sfhealth.example.com' do
    @hypertension_literature_review_task = create_task 'Hypertension literature review'
    @hypertension_literature_review_message = create_message(@hypertension_literature_review_task,
      text: (
        %(We've been missing high blood pressure pretty often in triage lately.  Per our discussion at the )+
        %(weekly meeting, let's do a literature review and see if we can update our standing order for )+
        %(antihypertensives.)
      )
    )
    add_conversation_to_group(@hypertension_literature_review_message , @triage_group)
  end

  as 'smaturin@sfhealth.example.com' do
    @corgi_conversation =create_conversation(
      subject:     'Look at these adorable corgis!',
      text:        "This is simply absurd.",
      groups:      [@social_group],
      attachments: [
        attachment('some.gif', 'image/gif'),
      ],
    )
  end

  as 'ritsuko@sfhealth.example.com' do
    reply_to @corgi_conversation, {
      body_plain: "We claim this stick in the name of England and Queen Elizabeth! And more!",
      stripped_plain: "We claim this stick in the name of England and Queen Elizabeth!",
    }
  end

  as 'amywong.phd@gmail.com' do
    reply_to @hypertension_literature_review_message, text: "Google Scholar is great for this. I'll see what I can find."
    @last_message = reply_to(@hypertension_literature_review_message,
      html: (
        %(I found a paper that looks promising, but I don't have access to the full text. Can anyone help me find it? Here's )+
        %(the citation:<br><br>Emergency Room Management of Hypertensive Urgencies and Emergencies<br>Donald G. Vidt MD<br>)+
        %(DOI: 10.1111/j.1524-6175.2001.00449.x")
      ),
      text: (
        %(I found a paper that looks promising, but I don't have access to the full text. Can anyone help me find it? Here's )+
        %(the citation:\n)+
        %(Emergency Room Management of Hypertensive Urgencies and Emergencies\n)+
        %(Donald G. Vidt MD\n)+
        %(DOI: 10.1111/j.1524-6175.2001.00449.x",\n)
      ),
    )
  end

  as 'sfmedstudent@gmail.com' do
    add_doer_to_task @hypertension_literature_review_task, 'amywong.phd@gmail.com'

    @last_message = reply_to(@last_message,
      html: "Oh, I have journal access here at the university. I'll see if I can track it down.<br><br>~Sandeep",
      text: "Oh, I have journal access here at the university. I'll see if I can track it down.\n\n~Sandeep",
    )
    @last_message = reply_to(@last_message,
      text: "I found it. Looks like Groups I and II both start at 180/110 mmHg. I've attached the PDF.",
      attachments: [
        attachment('some.txt', 'text/plain', false),
      ],
    )
  end

  as 'amywong.phd@gmail.com' do
    @last_message = reply_to(@last_message, text: "That looks great! Thanks, Sandeep!")
    mark_task_as_done @hypertension_literature_review_task
    mark_task_as_done @call_x_ray_machine_maintenance_company_task
    mark_task_as_done @check_in_with_iv_supplies_vendor_task
    mark_task_as_done @review_our_intake_policies_task
  end

  Timecop.return
end
