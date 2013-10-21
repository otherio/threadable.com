TestEnvironment::FixtureBuilder.new do

  # Amy signs up (we do this since this fixutre might run first)
  sign_up 'Amy Wong',  'amywong.phd@gmail.com', 'password'

  # Amy creates a project
  @project = Project.create!(
    name: 'SF Health Center',
    short_name: 'SFHealth',
    description: 'San Francisco Health Center',
  )
  project.members << user('Amy Wong')

  # Amy invites her project mates
  add_user 'Sandeep Prakash',  'sfmedstudent@gmail.com'
  add_user 'Lilith Sternin',   'lilith@sfhealth.example.com'
  add_user 'Anil Kapoor',        'anil@sfhealth.example.com'
  add_user 'Trapper John',   'trapper@sfhealth.example.com'
  add_user 'Marcus Welby',   'marcus@sfhealth.example.com'
  add_user 'Michaela Quinn',   'mquinn@sfhealth.example.com'
  add_user 'B.J. Hunnicutt',   'bj@sfhealth.example.com'
  add_user 'Stephen Maturin',   'smaturin@sfhealth.example.com'
  add_user 'Lisa Cuddy',   'lcuddy@sfhealth.example.com'
  add_user 'Gregory House',   'house@sfhealth.example.com'
  add_user 'Ritsuko Akagi',   'ritsuko@sfhealth.example.com'
  add_user 'Yuri Zhivago',   'yuriz@sfhealth.example.com'
  add_user 'Hans Zarkov',   'zarkov@sfhealth.example.com'
  add_user 'Peter Venkman',   'ecto@sfhealth.example.com'

  # add_user 'Peter Capaldi',   'who@sfhealth.example.com'
  # add_user 'Victor Ehrlich',   'victor@sfhealth.example.com'
  # add_user 'Sara Sitarides',   'sara@sfhealth.example.com'
  # add_user 'Nick Riviera',   'drnick@sfhealth.example.com'
  # add_user 'Katherine Pulaski',   'kpulaski@sfhealth.example.com'
  # add_user 'Abigail Bartlet',   'abby@sfhealth.example.com'
  # add_user 'Jack Griffin',   'jack@sfhealth.example.com'
  # add_user 'Douglas Howser',   'doogie@sfhealth.example.com'
  # add_user 'Doug Ross',   'doug@sfhealth.example.com'
  # add_user 'Peter Benton',   'peter@sfhealth.example.com'
  # add_user 'Jing-Mei Chen',   'deb@sfhealth.example.com'
  # add_user 'Elizabeth Corday',   'elizabethcorday@sfhealth.example.com'
  # add_user 'Richard Kimble',   'rk@sfhealth.example.com'
  # add_user 'Zachary Smith',   'smith@sfhealth.example.com'

  # Amy's project mates all accept their invites
  web_enable 'Sandeep Prakash', 'password'
  web_enable 'Lilith Sternin', 'password'
  web_enable 'Anil Kapoor', 'password'
  web_enable 'Trapper John', 'password'
  web_enable 'Marcus Welby', 'password'
  web_enable 'Michaela Quinn', 'password'
  web_enable 'B.J. Hunnicutt', 'password'
  web_enable 'Stephen Maturin', 'password'
  web_enable 'Lisa Cuddy', 'password'
  web_enable 'Gregory House', 'password'
  web_enable 'Ritsuko Akagi', 'password'
  web_enable 'Yuri Zhivago', 'password'
  web_enable 'Hans Zarkov', 'password'
  web_enable 'Peter Venkman', 'password'

  # web_enable 'Peter Capaldi', 'password'
  # web_enable 'Victor Ehrlich', 'password'
  # web_enable 'Sara Sitarides', 'password'
  # web_enable 'Nick Riviera', 'password'
  # web_enable 'Katherine Pulaski', 'password'
  # web_enable 'Abigail Bartlet', 'password'
  # web_enable 'Jack Griffin', 'password'
  # web_enable 'Lilith Sternin', 'password'
  # web_enable 'Douglas Howser', 'password'
  # web_enable 'Doug Ross', 'password'
  # web_enable 'Peter Benton', 'password'
  # web_enable 'Jing-Mei Chen', 'password'
  # web_enable 'Elizabeth Corday', 'password'
  # web_enable 'Richard Kimble', 'password'
  #web_enable 'Zachary Smith', 'password'

  # Zachary hates email
  # unsubscribe_from_project_email 'Zachary Smith'

  # everyone gets an avatar photo (except not because we don't have them yet)
  set_avatar 'sfmedstudent@gmail.com', 'sandeep.jpg'
  set_avatar 'amywong.phd@gmail.com', 'amy.jpg'
  set_avatar 'yuriz@sfhealth.example.com', 'yuri.jpg'

  set_avatar 'lilith@sfhealth.example.com', 'lilith.jpg'
  set_avatar 'anil@sfhealth.example.com', 'anil.jpg'
  set_avatar 'trapper@sfhealth.example.com', 'trapper.jpg'
  set_avatar 'marcus@sfhealth.example.com', 'marcus.jpg'
  set_avatar 'mquinn@sfhealth.example.com', 'mquinn.jpg'
  set_avatar 'bj@sfhealth.example.com', 'bj.jpg'
  set_avatar 'smaturin@sfhealth.example.com', 'stephen.jpg'
  set_avatar 'lcuddy@sfhealth.example.com', 'lisa.jpg'
  set_avatar 'house@sfhealth.example.com', 'house.jpg'
  set_avatar 'ritsuko@sfhealth.example.com', 'ritsuko.jpg'
  set_avatar 'zarkov@sfhealth.example.com', 'zarkov.gif'
  set_avatar 'ecto@sfhealth.example.com', 'venkman.jpg'


  #set_avatar 'elizabeth@sfhealth.example.com', ''
  #set_avatar 'anil@sfhealth.example.com', ''
  #set_avatar 'trapper@sfhealth.example.com', ''
  #set_avatar 'bj@sfhealth.example.com', ''
  #set_avatar 'smaturin@sfhealth.example.com', ''
  #set_avatar 'lcuddy@sfhealth.example.com', ''
  #set_avatar 'house@sfhealth.example.com', ''
  #set_avatar 'ritsuko@sfhealth.example.com', ''
  #set_avatar 'who@sfhealth.example.com', ''
  #set_avatar 'victor@sfhealth.example.com', ''
  #set_avatar 'sara@sfhealth.example.com', ''
  #set_avatar 'drnick@sfhealth.example.com', ''
  #set_avatar 'kpulaski@sfhealth.example.com', ''
  #set_avatar 'abby@sfhealth.example.com', ''
  #set_avatar 'zarkov@sfhealth.example.com', ''
  #set_avatar 'ecto@sfhealth.example.com', ''
  #set_avatar 'jack@sfhealth.example.com', ''
  #set_avatar 'lilith@sfhealth.example.com', ''
  #set_avatar 'doogie@sfhealth.example.com', ''
  #set_avatar 'doug@sfhealth.example.com', ''
  #set_avatar 'peter@sfhealth.example.com', ''
  #set_avatar 'deb@sfhealth.example.com', ''
  #set_avatar 'elizabethcorday@sfhealth.example.com', ''
  #set_avatar 'rk@sfhealth.example.com', ''
  #set_avatar 'smith@sfhealth.example.com', ''

  # Let's make some messages!
  send_message(
    user: 'Amy Wong',
    reply: false,
    subject: 'Welcome to our new Covered project!',
    stripped_plain: 'Hey all! I think we should try this way to organize our conversation and work. Thanks for joining up!',
    body_plain: 'Hey all! I think we should try this way to organize our conversation and work. Thanks for joining up!'
  )

  # Lisa replies to the welcome email
  send_message(
    user: 'Lisa Cuddy',
    reply: true,
    subject: 'RE: Welcome to our new Covered project!',
    stripped_plain: 'Yay! You go Amy. This tool looks radder than an 8-legged panda.',
    body_plain: 'Yay! You go Amy. This tool looks radder than an 8-legged panda.',
  )

  send_message(
    user: 'Peter Venkman',
    reply: false,
    subject: 'New hire orientation next wednesday',
    stripped_plain: 'This is a reminder for all new hires that the orientation meeting is next wednesday at 10am in room 2202. In the meantime, I encourage you to to review the SF Health employee policies online here: https://covered.sfhealth.com/hr/employee-policies/ and please feel free to ask me if you have any questions.',
    body_plain: 'This is a reminder for all new hires that the orientation meeting is next wednesday at 10am in room 2202. In the meantime, I encourage you to to review the SF Health employee policies online here: https://covered.sfhealth.com/hr/employee-policies/ and please feel free to ask me if you have any questions.',
  )

  send_message(
    user: 'Lilith Sternin',
    reply: false,
    subject: 'Free calendars & pen sets in the 2nd floor lunch room',
    stripped_plain: "The rep for Replexafil dropped off some 2014 Replexafil calendars and pen sets for us. They're in the 2nd floor lunch room if anyone wants one. Help yourself.",
    body_plain: "The rep for Replexafil dropped off some 2014 Replexafil calendars and pen sets for us. They're in the 2nd floor lunch room if anyone wants one. Help yourself.",
  )
  send_message(
    user: 'Ritsuko Akagi',
    reply: true,
    subject: 'RE: Free calendars & pen sets in the 2nd floor lunch room',
    stripped_plain: "Does anyone here still use paper calendars?",
    body_plain: "Does anyone here still use paper calendars?",
  )
  send_message(
    user: 'Stephen Maturin',
    reply: true,
    subject: 'RE: Free calendars & pen sets in the 2nd floor lunch room',
    stripped_plain: "That would be me. Haven't quite gotten the hang of my iPad yet. I'm afraid I'll still be using traditional scheduling tools for some time to come. Indeed, if anyone wishes to contact me, I'd encourage you to do so in person, as I hardly even have time to check my electronic mail these days. My sincere apologies.",
    body_plain: "That would be me. Haven't quite gotten the hang of my iPad yet. I'm afraid I'll still be using traditional scheduling tools for some time to come. Indeed, if anyone wishes to contact me, I'd encourage you to do so in person, as I hardly even have time to check my electronic mail these days. My sincere apologies.",
  )
  send_message(
    user: 'Lilith Sternin',
    reply: true,
    subject: 'RE: Free calendars & pen sets in the 2nd floor lunch room',
    stripped_plain: "Noted, Doc. I'll grab one of the calendars for you at lunch, and drop it by your office later.",
    body_plain: "Noted, Doc. I'll grab one of the calendars for you at lunch, and drop it by your office later.",
  )

  send_message(
    user: 'Peter Venkman',
    reply: false,
    subject: "2014 International Diagnostics Conference -- Who's going?",
    stripped_plain: "Registration for the 2013 IDCC is coming up. Is anyone planning on attending?",
    body_plain: "Registration for the 2013 IDCC is coming up. Is anyone planning on attending?",
  )
  send_message(
    user: 'Anil Kapoor',
    reply: true,
    subject: "RE: 2014 International Diagnostics Conference -- Who's going?",
    stripped_plain: "Where is it being held this year?",
    body_plain: "Where is it being held this year?",
  )
  send_message(
    user: 'Peter Venkman',
    reply: true,
    subject: "RE: 2014 International Diagnostics Conference -- Who's going?",
    stripped_plain: "In Seattle. Here's the conference website: http://www.idcconference.com",
    body_plain: "In Seattle. Here's the conference website: http://www.idcconference.com",
  )

  # make some tasks
  create_task 'Amy Wong',       'Call X-ray machine maintenance company'
  create_task 'Lilith Sternin', 'Review our intake policies'
  create_task 'B.J. Hunnicutt', 'Update EMS forms to new version'
  create_task 'Anil Kapoor',    'Replace the power cord for vitals monitor #4'

  create_task 'Lilith Sternin', 'New triage desk vitals monitor'  #triage

  create_task 'Amy Wong',  'Order more glucose monitoring supplies'

  create_task 'Lilith Sternin', 'Write current EMS practice review'  #triage

  create_task 'Lilith Sternin',        'Print new info signs for the front desk'
  create_task 'Anil Kapoor',    'Review literature on DVT prevention'
  create_task 'Anil Kapoor',    'Check in with IV supplies vendor'
  create_task 'Amy Wong',  'Revise PA paging procedures'

  create_task 'B.J. Hunnicutt', 'Review triage ECG procedures'  #triage
  create_task 'Anil Kapoor', 'Review standing orders for ASA and CP'  #triage

  create_task 'Amy Wong',  'Review shift-change procedures'
  create_task 'Yuri Zhivago',  'Present our new central line system to the department'
  create_task 'Peter Venkman',  'Set up conference room for orientation'

  create_task 'Amy Wong', 'Write new intake form'  #triage

  create_task 'Lilith Sternin',  'Pick up bagels for orientation'
  create_task 'Amy Wong',  'Pick up decorations for the halloween party'

  create_task 'Amy Wong', 'Compare waiting times to acuity'  #triage
  create_task 'B.J. Hunnicutt', 'Schedule a triage retrospective'  #triage
  create_task 'Anil Kapoor', 'Meet with SJ clinic about trauma classification'  #triage
  create_task 'Amy Wong', 'Summarize triage review findings for board'  #triage


  # fill out those tasks with some messages
  send_message(
    subject: 'Call X-ray machine maintenance company',
    stripped_plain: "Lorem ipsum dolor sit amet",
    body_plain: "Lorem ipsum dolor sit amet",
    reply: false,
  )
  send_message(
    subject: 'RE: Call X-ray machine maintenance company',
    stripped_plain: "Lorem ipsum dolor sit amet",
    body_plain: "Lorem ipsum dolor sit amet",
    reply: true,
  )
  send_message(
    subject: 'RE: Call X-ray machine maintenance company',
    stripped_plain: "Lorem ipsum dolor sit amet",
    body_plain: "Lorem ipsum dolor sit amet",
    user: 'Lilith Sternin',
    reply: true,
  )

  send_message(
    subject: 'Review our intake policies',
    stripped_plain: "Lorem ipsum dolor sit amet",
    body_plain: "Lorem ipsum dolor sit amet",
    user: 'Lilith Sternin',
    reply: true,
  )
  send_message(
    subject: 'RE: Review our intake policies',
    stripped_plain: "Lorem ipsum dolor sit amet",
    body_plain: "Lorem ipsum dolor sit amet",
    user: 'Anil Kapoor',
    reply: true,
  )

  add_doer_to_task 'Lilith Sternin', 'Review our intake policies'

  complete_task 'Lilith Sternin', 'Review our intake policies'
  complete_task 'Lilith Sternin', 'Call X-ray machine maintenance company'
  complete_task 'Lilith Sternin', 'Print new info signs for the front desk'
  complete_task 'Lilith Sternin', 'Pick up bagels for orientation'
  complete_task 'Lilith Sternin', 'Set up conference room for orientation'

  # More email conversations
  send_message(
    user: 'Anil Kapoor',
    reply: false,
    subject: 'Staff halloween party!',
    stripped_plain: 'Lorem upsum dolor sit amet',
    body_plain: 'Lorem upsum dolor sit amet'
  )

  # Demo thread.  Put this at the end so it shows up near the top of the list
  create_task 'Yuri Zhivago', 'Hypertension literature review'
  complete_task 'Lilith Sternin', 'Hypertension literature review'

  # send_message(
  #   user: 'Yuri Zhivago',
  #   reply: false,
  #   subject: 'Hypertension literature review',
  #   stripped_plain: "We've been missing high blood pressure pretty often in triage lately.  Per our discussion at the weekly meeting, let's do a literature review and see if we can update our standing order for antihypertensives.",
  #   body_plain: "We've been missing high blood pressure pretty often in triage lately.  Per our discussion at the weekly meeting, let's do a literature review and see if we can update our standing order for antihypertensives.",
  # )

  complete_task 'Lilith Sternin', 'Call X-ray machine maintenance company'
  complete_task 'Lilith Sternin', 'Check in with IV supplies vendor'
  complete_task 'Lilith Sternin', 'Review our intake policies'

end
