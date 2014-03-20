require File.expand_path('../spec_helper', __FILE__);

describe 'Signing up' do

  let(:user){ User.new }

  let(:organization_name){ "Test Organization #{user.uuid}" }
  let(:expected_organization_slug){ "test-organization-#{user.uuid}" }

  it 'should work' do
    visit '/'
    expect(page).to have_text 'Mailing lists evolved'
    expect(page).to be_at_path "/"

    within first('form') do
      fill_in 'Email address',     with: user.email_address
      fill_in 'Organization name', with: organization_name
      click_on 'CREATE YOUR LIST'
    end

    welcome_email = user.inbox.wait_for_message(subject: 'Welcome to Threadable!')
    expect(welcome_email).to be_present
    welcome_email_link = welcome_email.href_for_link("Click here to confirm your email and create your organization")

    visit welcome_email_link
    expect(page).to have_text 'Your organization'
    expect(page).to be_at_path '/create'

    fill_in 'Your name', with: user.name
    fill_in 'Password', with: user.password, match: :prefer_exact
    fill_in 'Password confirmation', with: user.password
    click_on 'Create'

    expect(page).to be_at_path "/#{expected_organization_slug}/my/conversations/compose"
    expect(page).to have_text user.name
    expect(page).to have_text user.email_address
    expect(page).to have_text 'Welcome to Threadable!'

    within('.sidebar'){ first('.user-controls').click }
    click_on 'Sign out'

    expect(page).to be_at_path '/'
    click_on 'SIGN IN'
    fill_in 'Email Address', with: user.email_address
    fill_in 'Password', with: user.password
    click_on 'Sign in'

    expect(page).to be_at_path "/#{expected_organization_slug}/my/conversations"
  end
end
