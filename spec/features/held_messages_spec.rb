require 'spec_helper'

feature "Held messages" do

  let(:project)       { covered.projects.find_by_slug! 'raceteam' }

  let(:from){ 'unknown person <tom.sucksateverything@example.com>' }
  let(:envelope_from){ 'tom.sucksateverything@example.com' }
  let(:email_subject){ "can I be on your project?" }
  let(:body){ "guys? I can totally do stuff. Please!" }

  before do
    held_message = covered.incoming_emails.create!(
      create_incoming_email_params(
        from:          from,
        envelope_from: 'tom.sucksateverything@example.com',
        recipient:     project.email_address,
        to:            project.formatted_email_address,
        subject:       email_subject,
        body_plain:    body,
        body_html:     body,
      )
    )
    drain_background_jobs!
    held_message.incoming_email_record.reload
    expect(held_message).to be_held

    held_message_notification_email = sent_emails.to('tom.sucksateverything@example.com').with_subject("[message held] #{email_subject}").first

    # TODO: expand this test to look at some of the stuff that's checked in process_incoming_email_spec. It probably belongs here more.
    expect(held_message_notification_email).to be_present
    expect(held_message_notification_email.text_content).to include project.name
    expect(held_message_notification_email.text_content).to include email_subject

    sign_in_as 'tom@ucsd.covered.io'
    visit project_conversation_url(project, 'can-i-be-on-your-project')
    expect(page).to have_text %(We couldn't find the page you were looking for.)

    visit project_conversations_url(project)
    click_on '1 held message'

    expect(page).to have_text email_subject
    expect(page).to_not have_text body
  end

  scenario %(accepting a held message) do
    within('tr', text: email_subject){ click_on 'Accept' }
    expect(page).to have_text 'Notice! the message was accepted'
    expect(page).to_not have_text email_subject

    drain_background_jobs!

    visit project_conversation_url(project, 'can-i-be-on-your-project')
    expect(page).to have_text from
    expect(page).to have_text body

    accepted_message_notification_email = sent_emails.to('tom.sucksateverything@example.com').with_subject("[message accepted] #{email_subject}").first
    expect(accepted_message_notification_email).to be_present
    expect(accepted_message_notification_email.text_content).to include project.name
    expect(accepted_message_notification_email.text_content).to include email_subject
  end

  scenario %(rejecting a held message) do
    within('tr', text: email_subject){ click_on 'Reject' }
    expect(page).to have_text 'Notice! the message was rejected'

    drain_background_jobs!

    visit project_conversation_url(project, 'can-i-be-on-your-project')
    expect(page).to have_text %(We couldn't find the page you were looking for.)

    rejected_message_notification_email = sent_emails.to('tom.sucksateverything@example.com').with_subject("[message rejected] #{email_subject}").first
    expect(rejected_message_notification_email).to be_present
    expect(rejected_message_notification_email.text_content).to include project.name
    expect(rejected_message_notification_email.text_content).to include email_subject
  end


end
