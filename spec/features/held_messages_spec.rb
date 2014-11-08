require 'spec_helper'

feature "Held messages" do

  let(:organization)       { threadable.organizations.find_by_slug! 'raceteam' }

  let(:from){ 'unknown person <tom.sucksateverything@example.com>' }
  let(:envelope_from){ 'tom.sucksateverything@example.com' }
  let(:email_subject){ "can I be on your organization?" }
  let(:body){ "guys? I can totally do stuff. Please!" }

  before do
    held_message = threadable.incoming_emails.create!(
      create_incoming_email_params(
        from:          from,
        envelope_from: 'tom.sucksateverything@example.com',
        recipient:     organization.email_address,
        to:            organization.formatted_email_address,
        subject:       email_subject,
        body_plain:    body,
        body_html:     body,
      )
    ).first
    drain_background_jobs!
    held_message.incoming_email_record.reload
    expect(held_message).to be_held

    held_message_notification_email = sent_emails.to('tom.sucksateverything@example.com').with_subject("[message held] #{email_subject}").first

    # TODO: expand this test to look at some of the stuff that's checked in process_incoming_email_spec. It probably belongs here more.
    expect(held_message_notification_email).to be_present
    expect(held_message_notification_email.text_content).to include organization.name
    expect(held_message_notification_email.text_content).to include email_subject

    sign_in_as 'tom@ucsd.example.com'
    visit conversation_url(organization, 'raceteam', 'can-i-be-on-your-organization')
    expect(page).to_not have_text email_subject

    visit conversations_url(organization, 'raceteam')
    expect(page).to have_text "Held Messages"
    click_on 'held messages'
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)

    expect(page).to have_text email_subject
    expect(page).to_not have_text body
    expect(page).to have_text organization.groups.primary.name

    click_on email_subject
    expect(page).to have_text email_subject
    expect(page).to have_text body
    expect(page).to have_text organization.groups.primary.name
  end

  scenario %(accepting a held message) do
    click_on 'Accept'
    # expect(page).to have_text 'Notice! the message was accepted'
    expect(page).to_not have_text email_subject

    drain_background_jobs!

    visit conversation_url(organization, 'raceteam', 'can-i-be-on-your-organization')
    expect(page).to have_text from
    expect(page).to have_text body

    accepted_message_notification_email = sent_emails.to('tom.sucksateverything@example.com').with_subject("[message accepted] #{email_subject}").first
    expect(accepted_message_notification_email).to be_present
    expect(accepted_message_notification_email.text_content).to include organization.name
    expect(accepted_message_notification_email.text_content).to include email_subject
  end

  scenario %(rejecting a held message) do
    click_on 'Reject'
    # expect(page).to have_text 'Notice! the message was rejected'

    drain_background_jobs!

    visit conversation_url(organization, 'raceteam', 'can-i-be-on-your-organization')
    expect(page).to_not have_text email_subject

    rejected_message_notification_email = sent_emails.to('tom.sucksateverything@example.com').with_subject("[message rejected] #{email_subject}").first
    expect(rejected_message_notification_email).to be_present
    expect(rejected_message_notification_email.text_content).to include organization.name
    expect(rejected_message_notification_email.text_content).to include email_subject
  end


end
