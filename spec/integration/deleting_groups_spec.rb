require 'spec_helper'

describe 'deleting groups' do

  let(:organization){ threadable.organizations.find_by_slug!('raceteam') }
  let(:conversation){ threadable.organizations.find_by_slug!('raceteam') }

  context 'send conversation messages that are in a group that has been deleted' do
    it 'finds a way!' do
      sign_in_as 'alice@ucsd.example.com'
      create_group!
      create_message!
      assert_message_job_is_enqued!
      delete_group!
      assert_email_was_sent!
    end

    def assert_email_was_sent!
      expect{ drain_background_jobs! }.to_not raise_error
      sent_emails.each do |sent_email|
        expect( sent_email.from               ).to eq [current_user.email_address.to_s]
        expect( sent_email.subject            ).to eq "[RaceTeam] I made my first sale!"
        expect( sent_email.smtp_envelope_from ).to eq organization.email_address.to_s
      end
    end

  end

  context 'accepting incoming emails to groups that no longer exist' do
    it 'finds a way!' do
      sign_in_as 'alice@ucsd.example.com'
      create_group!
      create_message!
      drain_background_jobs!
      sent_emails.clear
      delete_group!
      reply_to_message!
      assert_email_was_received!
    end

    def reply_to_message!
      params = create_incoming_email_params(
        subject:       @message.subject,

        from:          'Ricky Bobby <ricky.bobby@ucsd.example.com>',
        envelope_from: 'ricky.bobby@ucsd.example.com',

        recipient:     'raceteam+saels@localhost',
        to:            '"UCSD Electric Racing: Saels" <raceteam+saels@localhost>',

        in_reply_to:   @message.message_id_header,
        references:    [@message.message_id_header],

        body_html:     '<p>congratz!</p>',
        body_plain:    'congratz!',
        stripped_html: '<p>congratz!</p>',
        stripped_text: 'congratz!',
      )
      post emails_url, params
      expect(response).to be_ok
    end

    def assert_email_was_received!
      drain_background_jobs!
      @incoming_email = threadable.incoming_emails.latest
      expect(@incoming_email).to be_delivered
      expect(@incoming_email.message.parent_message).to eq @message
      expect(@incoming_email.conversation.groups.all).to be_empty
    end
  end

  def create_group!
    @group = organization.groups.create!(name: 'Saels', auto_join: true)
    drain_background_jobs!
    sent_emails.clear
  end

  def create_message!
    @conversation = organization.conversations.create!(
      creator: current_user,
      subject: 'I made my first sale!',
    )
    @conversation.groups.add(@group)
    @message = @conversation.messages.create!(
      creator: current_user,
      subject: 'I made my first sale!',
      text: 'I rock!',
    )
  end

  def assert_message_job_is_enqued!
    @message.recipients.all.each do |recipient|
      next if recipient.same_user? current_user
      assert_background_job_enqueued SendEmailWorker, args: [threadable.env, "conversation_message", organization.id, @message.id, recipient.id]
    end
  end

  def delete_group!
    @group.destroy
  end

end
