require 'spec_helper'

describe Threadable::MailgunEvent do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:recipient)    { organization.members.find_by_email_address('alice@ucsd.example.com') }
  let(:conversation) { organization.conversations.find_by_slug('welcome-to-our-threadable-organization') }
  let(:message)      { conversation.messages.all.first }

  let(:params) do
    {
      'event'           => event,
      'recipient'       => recipient.email_address.to_s,
      'domain'          => 'threadable.com',
      'message-headers' => headers.to_json,
      'organization'    => organization.slug,
      'recipient-id'    => recipient.id,
      'Message-Id'      => message.message_id_header,
      "timestamp"       => 'timestamp',
      "token"           => 'token',
      "signature"       => 'signature',
    }
  end

  before do
    params.merge! type_specific_params
  end

  delegate :call, to: described_class

  context 'with the "opened" event' do
    let(:event) { 'opened' }
    let(:user_agent) { 'Apple Mail/foo 7.1' }

    let(:type_specific_params) do
      {
        "ip"          => '0.0.0.0',
        "country"     => 'us',
        "region"      => 'ca',
        "city"        => 'san francisco',
        "user-agent"  => user_agent,
        "device-type" => 'mobile',
        "client-type" => 'email client',
        "client-name" => 'Apple Mail',
        "client-os"   => 'OSX',
      }
    end

    it 'tracks the open in mixpanel' do
      call(threadable, params)

      assert_tracked(recipient.id, "Opened Message",
        "ip"           => '0.0.0.0',
        "country"      => 'us',
        "region"       => 'ca',
        "city"         => 'san francisco',
        "user-agent"   => 'Apple Mail/foo 7.1',
        "device-type"  => 'mobile',
        "client-type"  => 'email client',
        "client-name"  => 'Apple Mail',
        "client-os"    => 'OSX',
        "organization" => organization.slug,
      )
    end

    context 'with a gmail message' do
      let(:user_agent) { 'Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7 (via ggpht.com GoogleImageProxy)' }

      it "corrects the client info based on gmail's fake user agent string" do
        call(threadable, params)

        assert_tracked(recipient.id, "Opened Message",
          "ip"           => '0.0.0.0',
          "country"      => 'us',
          "region"       => 'ca',
          "city"         => 'san francisco',
          "user-agent"   => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7 (via ggpht.com GoogleImageProxy)',
          "device-type"  => 'mobile',
          "client-type"  => 'email client',
          "client-name"  => 'GMail',
          "client-os"    => 'Unknown',
          "organization" => organization.slug,
        )
      end
    end

  end

  context 'with the "complained" event' do
    let(:event) { 'complained' }

    let(:type_specific_params) { {} }

    it 'tracks the complaint in mixpanel and sends an email to let us know' do
      call(threadable, params)

      assert_tracked(recipient.id, "Spam Complaint",
        "conversation"  => conversation.slug,
        "subject"       => message.subject,
        "organization"  => organization.slug,
      )

      drain_background_jobs!

      expect(sent_emails.with_subject('Spam complaint').first).to be
    end

  end

end
