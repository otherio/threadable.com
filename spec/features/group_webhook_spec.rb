require 'spec_helper'

feature "Group web hook" do

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  scenario %(adding a web hook) do
    visit root_url

    within selector_for('the sidebar') do
      within 'li.group', text: '+Fundraising' do
        find('.disclosure-triangle').click
        sleep 0.2
        click_on "Settings"
      end
    end

    expect(page).to have_text "Changes made here will affect everybody in the group. Be careful!"

    click_on 'Show experimental options'

    fill_in 'Webhook URL:', with: 'a'
    click_on 'Update group settings'

    expect(page).to have_text 'Error: Validation failed: Webhook url'
    expect(page).to be_at_url group_settings_url('raceteam', 'fundraising')

    fill_in 'Webhook URL:', with: webhook_url
    click_on 'Update group settings'
    expect(page).to be_at_url conversations_url('raceteam', 'fundraising')

    incoming_email = send_email(
      to:         'raceteam+fundraising@127.0.0.1',
      recipient:  'raceteam+fundraising@127.0.0.1',
      subject:    'Testing the new webhook',
      body_html:  '<p>this is a test message<p/>',
      body_plain: 'this is a test message',
    )

    visit conversations_url('raceteam', 'fundraising')

    click_on 'Testing the new webhook'
    expect(page).to have_text 'HOOKED! this is a test message'
  end


  def send_email options
    options[:from] ||= threadable.current_user.formatted_email_address
    incoming_email = threadable.incoming_emails.create!(create_incoming_email_params(options)).first
    drain_background_jobs!
    incoming_email.reload!
  end



  let :webhook_app do
    Class.new(Sinatra::Base) do
      post '/threadable_hook' do
        content_type :json
        params.keys.each do |key|
          next unless params[key].is_a?(String)
          params[key] = "HOOKED! #{params[key]}"
        end
        params.to_json
      end
    end
  end

  let :webhook_server do
    Capybara::Server.new(webhook_app, nil).boot
  end

  let :webhook_url do
    "http://#{webhook_server.host}:#{webhook_server.port}/threadable_hook"
  end

end
