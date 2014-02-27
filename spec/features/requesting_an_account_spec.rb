require 'spec_helper'

feature "requesting an account" do

  scenario %(with a new email address), fixtures: false do
    request_account! 'Zero point energy machine', 'john@the-hutchison-effect.org'
    request_account! 'Zero point energy machine', 'john@the-hutchison-effect.org'
  end

  scenario %(with an existing user's email address), fixtures: false do
    request_account! 'Face Team', 'alice@ucsd.example.com'
  end

  def request_account! organization_name, email_address
    sent_emails.clear

    visit root_url
    assert_tracked(nil, 'Homepage visited')

    fill_in 'Organization name', with: organization_name
    fill_in 'Email address', with: email_address
    expect{ click_on 'Request account' }.to change{ AccountRequest.count }.by(1)

    expect(page).to have_text 'click the link in your email'

    account_request = AccountRequest.last
    expect(account_request.organization_name).to eq organization_name
    expect(account_request.email_address    ).to eq email_address

    assert_tracked(nil, 'Account requested',{
      account_request_id: account_request.id,
      organization_name:  account_request.organization_name,
      email_address:      account_request.email_address,
    })

    assert_background_job_enqueued SendEmailWorker, args: [threadable.env, "account_request_confirmation", account_request.id]

    drain_background_jobs!

    email = sent_emails.to(email_address).with_subject("Threadable account request").last
    expect(email).to be_present

    visit email.link("Click here to confirm your account request")[:href]
    expect(page).to have_text 'Thanks for requesting an account!'
    account_request.reload
    expect(account_request).to be_confirmed

    assert_tracked(nil, 'Account request confirmed',{
      account_request_id: account_request.id,
      organization_name:  account_request.organization_name,
      email_address:      account_request.email_address,
    })
  end

end
