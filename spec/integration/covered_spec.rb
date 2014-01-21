require 'spec_helper'

describe "covered", fixtures: false do
  # it "should work" do
  #   expect{ Covered.new }.to raise_error ArgumentError, 'required options: :host'

  #   prank_calls = covered.organizations.create! name: 'Prank Calls'
  #   expect(prank_calls.class).to eq Covered::Organization
  #   expect(prank_calls).to be_persisted
  #   expect(prank_calls.members.all).to be_empty
  #   expect(prank_calls.organization_record).to eq Organization.last


  #   expect(prank_calls.members.class       ).to eq Covered::Organization::Members
  #   expect(prank_calls.conversations.class ).to eq Covered::Organization::Conversations
  #   expect(prank_calls.messages.class      ).to eq Covered::Organization::Messages
  #   expect(prank_calls.tasks.class         ).to eq Covered::Organization::Tasks

  #   frank = covered.users.create! name: 'Frank Rizzo', email_address: 'frak@rizz.io'
  #   expect(frank.class).to eq Covered::User
  #   expect(frank.user_record).to eq User.last

  #   frank_membership = prank_calls.members.add user: frank
  #   expect(frank_membership.class).to eq Covered::Organization::Member

  #   expect(prank_calls.members).to include frank
  #   expect(Organization.last.members).to include frank.user_record
  # end

  it 'email addresses' do
    jared = covered.users.create! name: 'Jared Grippe', email_address: 'jared@other.io'
    expect( jared                           ).to be_a Covered::User
    expect( jared.email_address             ).to eq 'jared@other.io'
    expect( jared.email_addresses           ).to be_a Covered::User::EmailAddresses
    expect( jared.email_addresses.count     ).to eq 1

    jared_at_other_io = jared.email_addresses.all.first
    expect( jared_at_other_io         ).to be_a Covered::User::EmailAddress
    expect( jared_at_other_io.address ).to eq 'jared@other.io'
    expect( jared_at_other_io         ).to be_primary

    jared.email_addresses.add('jared@deadlyicon.com')
    expect( jared.email_address         ).to eq 'jared@other.io'
    expect( jared.email_addresses.count ).to eq 2

    jared_at_deadlyicon_dot_com = jared.email_addresses.all.find{|e| e.address == 'jared@deadlyicon.com' }
    expect( jared_at_deadlyicon_dot_com         ).to be_a Covered::User::EmailAddress
    expect( jared_at_deadlyicon_dot_com.address ).to eq 'jared@deadlyicon.com'
    expect( jared_at_deadlyicon_dot_com         ).to_not be_primary
    expect( jared_at_deadlyicon_dot_com         ).to_not be_confirmed

    jared_at_deadlyicon_dot_com.confirm!
    expect( jared_at_deadlyicon_dot_com ).to be_confirmed

    jared_at_deadlyicon_dot_com.primary!
    jared.reload
    expect( jared.email_address ).to eq 'jared@deadlyicon.com'

    expect( jared.email_addresses.all.map{|e| [e.address, e.primary?] }.to_set ).to eq Set[
      ['jared@other.io',       false],
      ['jared@deadlyicon.com', true ],
    ]
  end

  it "has the expected accessors" do
    expect( covered                 ).to be_a Covered::Class
    expect( covered.protocol        ).to eq 'http'
    expect( covered.host            ).to eq '127.0.0.1'
    expect( covered.email_host      ).to eq '127.0.0.1'
    expect( covered.port            ).to eq Capybara.server_port
    expect( covered.tracker         ).to be_a Covered::InMemoryTracker
    expect( covered.current_user_id ).to be_nil
    expect( covered.current_user    ).to be_nil

    expect( covered.emails          ).to be_a Covered::Emails
    expect( covered.email_addresses ).to be_a Covered::EmailAddresses
    expect( covered.users           ).to be_a Covered::Users
    expect( covered.organizations        ).to be_a Covered::Organizations
    expect( covered.conversations   ).to be_a Covered::Conversations
    expect( covered.tasks           ).to be_a Covered::Tasks
    expect( covered.messages        ).to be_a Covered::Messages
    expect( covered.attachments     ).to be_a Covered::Attachments
    expect( covered.incoming_emails ).to be_a Covered::IncomingEmails
  end

  def sign_up! options
    covered.current_user = covered.users.create! options
  end

  context "creating a organization, inviting members, creating and replying to conversations" do
    it "should work" do
      jared = sign_up! name: 'Jared Grippe', email_address: 'jared@other.io'
      expect(covered.current_user).to be_the_same_user_as jared

      other = jared.organizations.create! name: 'other.io'

      assert_background_job_not_enqueued SendEmailWorker, args: [covered.env, "join_notice", other.id, jared.id, nil]

      expect(other.members).to include jared

      nicole = other.members.add name: 'Nicole Aptekar',  email_address: 'nicole@other.io'
      aaron  = other.members.add name: 'Aaron Muszalski', email_address: 'aaron@other.io'
      ian    = other.members.add name: 'Ian Baker',       email_address: 'ian@other.io'

      expect(nicole).to be_a Covered::Organization::Member
      expect(aaron ).to be_a Covered::Organization::Member
      expect(ian   ).to be_a Covered::Organization::Member

      assert_background_job_enqueued SendEmailWorker, args: [covered.env, "join_notice", other.id, nicole.id, nil]
      assert_background_job_enqueued SendEmailWorker, args: [covered.env, "join_notice", other.id, aaron.id, nil]
      assert_background_job_enqueued SendEmailWorker, args: [covered.env, "join_notice", other.id, ian.id, nil]

      drain_background_jobs!

      expect( sent_emails.map(&:to).flatten.to_set ).to eq Set["nicole@other.io", "aaron@other.io", "ian@other.io"]
      sent_emails.clear

      welcome_conversation = other.conversations.create!(
        creator: current_user,
        subject: 'Welcome to the new other mailing list',
      )
      expect( welcome_conversation.class       ).to eq Covered::Conversation
      expect( welcome_conversation.slug        ).to eq "welcome-to-the-new-other-mailing-list"
      expect( welcome_conversation.creator_id  ).to eq current_user.id
      expect( welcome_conversation.creator     ).to eq current_user
      msg = welcome_conversation.messages.create!(
        creator: current_user,
        body: 'Hey guys. Covered is amazing.',
      )

      assert_background_job_not_enqueued SendEmailWorker, args: [covered.env, "conversation_message", other.id, msg.id, jared.id]
      assert_background_job_enqueued     SendEmailWorker, args: [covered.env, "conversation_message", other.id, msg.id, nicole.id]
      assert_background_job_enqueued     SendEmailWorker, args: [covered.env, "conversation_message", other.id, msg.id, aaron.id]
      assert_background_job_enqueued     SendEmailWorker, args: [covered.env, "conversation_message", other.id, msg.id, ian.id]

      drain_background_jobs!

      expect( sent_emails.sent_to("jared@other.io" ).with_subject("[other io] Welcome to the new other mailing list") ).to_not be_present
      expect( sent_emails.sent_to("nicole@other.io").with_subject("[other io] Welcome to the new other mailing list") ).to be_present
      expect( sent_emails.sent_to("aaron@other.io" ).with_subject("[other io] Welcome to the new other mailing list") ).to be_present
      expect( sent_emails.sent_to("ian@other.io"   ).with_subject("[other io] Welcome to the new other mailing list") ).to be_present


      # create a task

      # add some doers

      # check them emails


    end
  end

  context "prcessing an incoming email" do
    it "should work" do
      aaron = sign_up! name: 'Arron Burrr', email_address: 'aaron@burrr.me'
      expect(covered.current_user).to be_the_same_user_as aaron

      expect( aaron.class ).to eq Covered::User
      expect( aaron.user_record ).to eq User.last

      expect( aaron.email_addresses.class ).to eq Covered::User::EmailAddresses
      expect( aaron.organizations.class        ).to eq Covered::User::Organizations
      expect( aaron.messages.class        ).to eq Covered::User::Messages

      htp = aaron.organizations.create! name: 'Hug the police!'
      expect( htp.class ).to eq Covered::Organization
      expect( htp.organization_record ).to eq Organization.last

      assert_background_job_not_enqueued SendEmailWorker, args: [covered.env, "join_notice", htp.id, aaron.id, nil]

      expect( htp.members.class       ).to eq Covered::Organization::Members
      expect( htp.conversations.class ).to eq Covered::Organization::Conversations
      expect( htp.messages.class      ).to eq Covered::Organization::Messages
      expect( htp.tasks.class         ).to eq Covered::Organization::Tasks

      expect( htp.members ).to include aaron

      fat_cops = htp.conversations.create!(
        creator: current_user,
        subject: 'fat cops are so squishy',
      )
      expect( fat_cops.class ).to eq Covered::Conversation
      expect( fat_cops.slug  ).to eq "fat-cops-are-so-squishy"
      expect( fat_cops.task? ).to be_false

      expect( fat_cops.creator.class      ).to eq Covered::Conversation::Creator
      expect( fat_cops.events.class       ).to eq Covered::Conversation::Events
      expect( fat_cops.messages.class     ).to eq Covered::Conversation::Messages
      expect( fat_cops.recipients.class   ).to eq Covered::Conversation::Recipients
      expect( fat_cops.participants.class ).to eq Covered::Conversation::Participants

      expect( htp.conversations.find_by_slug!(fat_cops.slug) ).to eq fat_cops
      fat_cops = htp.conversations.find_by_slug! fat_cops.slug
      expect( fat_cops.class ).to eq Covered::Conversation

      msg1 = fat_cops.messages.create!(
        creator: current_user,
        html: "<p>OMG I love their belly fat</p>",
        sent_via_web: true
      )
      expect( msg1.class             ).to eq Covered::Message
      expect( msg1.subject           ).to eq fat_cops.subject
      expect( msg1.body              ).to eq "<p>OMG I love their belly fat</p>"
      expect( msg1.root?             ).to be_true
      expect( msg1.shareworthy?      ).to be_false
      expect( msg1.knowledge?        ).to be_false
      expect( msg1.message_id_header ).to match /\<(.*?)@/

      assert_background_job_enqueued SendEmailWorker, args: [covered.env, "conversation_message", htp.id, msg1.id, aaron.id]
      drain_background_jobs!

      expect(sent_emails.size).to eq 1
      email = sent_emails.first
      expect(email.text_content).to include 'OMG I love their belly fat'
      expect(email.text_content).to include 'support@127.0.0.1'
      expect(email.text_content).to include '%5Btask%5D%20'
      expect(email.html_content).to include "<p>OMG I love their belly fat</p>"
      expect(email.html_content).to include "feedback"
      expect(email.urls.map(&:to_s)).to include organization_url(htp)
      expect(email.urls.map(&:to_s)).to include conversation_url(htp, 'my', fat_cops, anchor: "message-#{msg1.id}")
      expect(email.organization_unsubscribe_url).to be_present

      sent_emails.clear

      date_header = 5.minutes.ago.rfc2822
      msg2 = fat_cops.messages.create!(
        creator:           current_user,
        sent_via_web:      true,
        message_id_header: '<CABQbZc9oj=-_0WwB2eZKq6xLwaM2-b_X2rdjuC5qt-NFi1gDHw@mail.gmail.com>',
        references_header: msg1.message_id_header,
        date_header:       date_header,
        subject:           "RE: #{msg1.subject}",
        parent_message:    msg1,
        from:              aaron.formatted_email_address,
        body_plain:        %(I like to pinch their belly buttons\n> OMG I love their belly fat),
        body_html:         %(<p>I like to pinch their belly buttons</p>\n<blockquote><p>OMG I love their belly fat</p></blockquote>),
        stripped_plain:    %(I like to pinch their belly buttons),
        stripped_html:     %(<p>I like to pinch their belly buttons</p>),
        attachments:       [],
      )

      assert_background_job_enqueued SendEmailWorker, args: [covered.env, "conversation_message", htp.id, msg2.id, aaron.id]

      expect( msg2.unique_id         ).to eq 'PENBQlFiWmM5b2o9LV8wV3dCMmVaS3E2eEx3YU0yLWJfWDJyZGp1QzVxdC1ORmkxZ0RId0BtYWlsLmdtYWlsLmNvbT4='
      expect( msg2.to_param          ).to eq "#{msg2.id}"
      expect( msg2.parent_message    ).to eq msg1
      expect( msg2.from              ).to eq 'Arron Burrr <aaron@burrr.me>'
      expect( msg2.subject           ).to eq "RE: #{msg1.subject}"
      expect( msg2.html?             ).to be_true
      expect( msg2.root?             ).to be_false

      expect( msg2.body              ).to eq %(<p>I like to pinch their belly buttons</p>\n<blockquote><p>OMG I love their belly fat</p></blockquote>)
      expect( msg2.body_plain        ).to eq %(I like to pinch their belly buttons\n> OMG I love their belly fat)
      expect( msg2.body_html         ).to eq %(<p>I like to pinch their belly buttons</p>\n<blockquote><p>OMG I love their belly fat</p></blockquote>)
      expect( msg2.stripped_plain    ).to eq %(I like to pinch their belly buttons)
      expect( msg2.stripped_html     ).to eq %(<p>I like to pinch their belly buttons</p>)
      expect( msg2.shareworthy?      ).to be_false
      expect( msg2.knowledge?        ).to be_false
      expect( msg2.message_id_header ).to eq '<CABQbZc9oj=-_0WwB2eZKq6xLwaM2-b_X2rdjuC5qt-NFi1gDHw@mail.gmail.com>'
      expect( msg2.references_header ).to eq msg1.message_id_header
      expect( msg2.date_header       ).to eq date_header

      drain_background_jobs!

      expect(sent_emails.size).to eq 1
      email = sent_emails.first
      expect(email.text_content).to include 'I like to pinch their belly buttons'
      expect(email.text_content).to include 'OMG I love their belly fat'
      expect(email.html_content).to include "<p>I like to pinch their belly buttons</p>"
      expect(email.html_content).to include "<p>OMG I love their belly fat</p>"
      expect(email.urls.map(&:to_s)).to include organization_url(htp)
      expect(email.urls.map(&:to_s)).to include conversation_url(htp, 'my', fat_cops, anchor: "message-#{msg2.id}")
      expect(email.organization_unsubscribe_url).to be_present
    end
  end

end
