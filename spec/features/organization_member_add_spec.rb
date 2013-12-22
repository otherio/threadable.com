require 'spec_helper'

feature "Project member add" do


  before do
    sign_in_as 'tom@ucsd.covered.io'
  end

  let(:project){ current_user.projects.find_by_slug! 'raceteam' }

  # this used to be called the invite modal
  scenario %(adding a member to a project) do
    click_on 'UCSD Electric Racing'
    click_on 'Add'
    fill_in "Name", with: 'Foo Guy'
    fill_in "Email", with: 'foo@guy.com'
    fill_in "Message", with: 'Hi i like you'
    click_on 'Add member'

    expect(page).to have_text 'Hey! Foo Guy <foo@guy.com> was added to this project.'

    click_on 'Members'

    expect(page).to have_text 'Foo Guy'

    foo_guy = project.members.find_by_user_slug!('foo-guy')

    assert_background_job_enqueued SendEmailWorker, args: [covered.env, "join_notice", project.id, foo_guy.id, 'Hi i like you']

    drain_background_jobs!

    email = sent_emails.sent_to('foo@guy.com').with_subject("You've been added to UCSD Electric Racing").first
    expect(email).to be_present
    expect(email.text_content).to include 'Hi i like you'
  end

end
