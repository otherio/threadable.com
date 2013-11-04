# Encoding: UTF-8
require 'spec_helper'

describe "email" do

  before do
    ActionMailer::Base.stub(:default_url_options).and_return(host: 'covered.io')
  end

  let(:project) { Covered::Project.where(name: "UCSD Electric Racing").first! }
  let(:sender){ Covered::User.with_email('alice@ucsd.covered.io').first! }
  let(:conversation){ project.conversations.where(subject: 'layup body carbon').first! }

  context "recieving from mailgun" do

    def filter_body(body)
      controller.covered.operations.strip_user_specific_content_from_email_message_body(body: body)
    end

    let(:parent_message){ conversation.messages.first! }

    let :message_headers do
      {
        'Message-Id' => '<youioyiuoy@lolz.io>',
        'In-Reply-To' => parent_message.message_id_header,
      }
    end

    let(:params) {
      create_incoming_email_params('message-headers' => message_headers)
    }

    context "when the signature is invalid" do
      it "should not so anything and render a bad request" do
        post '/emails', params.merge('signature' => 'badsignature')
        expect(response).to_not be_success
      end
    end

    context "when the signature is valid" do

      before do
        attachments_for_email_params(params).each do |attachment|
          mock_filepicker_upload_for(attachment)
        end
      end

      it "should create a message" do
        expect{
          post '/emails', params
        }.to change{ Covered::IncomingEmail.count }.by(1)
        expect(response).to be_success

        incoming_email_id = Covered::IncomingEmail.last.id

        assert_background_job_enqueued(controller.covered, :process_incoming_email, incoming_email_id: incoming_email_id)

        ->{ run_background_jobs! }.should change{ Covered::Message.count }.by(1)
        message = Covered::Message.last

        expect(message.message_id_header).to     eq message_headers['Message-Id']
        expect(message.subject).to               eq params['subject']
        expect(message.parent_message).to        eq parent_message
        expect(message.user).to                  eq sender
        expect(message.from).to                  eq sender.email
        expect(message.body_plain).to            eq filter_body(params['body-plain'])
        expect(message.body_html).to             eq filter_body(params['body-html'])
        expect(message.stripped_plain).to        eq filter_body(params['stripped-text'])
        expect(message.stripped_html).to         eq filter_body(params['stripped-html'])
        expect(message.conversation).to          eq conversation
        expect(message.conversation.project).to  eq project

        attachment_filenames = message.attachments.map(&:filename).to_set
        expected_attachment_filenames = 1.upto(3).map{|n| params["attachment-#{n}"].original_filename}.to_set
        # TODO check file body and encodings

        # TODO this should check file contents but encoding is hard :(
        expect(attachment_filenames).to eq expected_attachment_filenames

        assert_background_job_enqueued(controller.covered, :send_conversation_message, message_id: message.id)

        run_background_jobs!

        mail_recipients = (project.members_who_get_email - [message.user])

        expected_messages = mail_recipients.map do |mail_recipient|
          {
            from: "alice@ucsd.covered.io",
            to: [mail_recipient.email],
            subject: "✔ [RaceTeam] this is the subject",
          }
        end.to_set

        sent_messages = ActionMailer::Base.deliveries.map do |message|
          {
            from: message.from,
            to: message.to,
            subject: message.subject,
          }
        end

        expect(sent_messages).to eq sent_messages

      end
    end
  end

  context "recieving from the website" do

    before do
      sign_in_as sender
    end

    context "replying to an existing conversation" do

      let(:body){ Faker::Email.plain_body }
      let(:params){ {message: {body: body} } }

      it "should create a message and send emails through mailgun" do
        ->{
          xhr :post, project_conversation_messages_path(project, conversation), params
          response.should be_success
        }.should change{ Covered::Message.count }.by(1)

        message = Covered::Message.last
        message.from.should == sender.email
        message.user_id.should == sender.id
        message.subject.should == conversation.subject
        message.body_plain.should == body
        message.message_id_header.should be_present

        assert_background_job_enqueued(controller.covered, :send_conversation_message, message_id: message.id, email_sender: true)

        run_background_jobs!

        project.members_who_get_email.each do |recipient|
          assert_background_job_enqueued(controller.covered, :send_email,
            type: 'conversation_message',
            options: {message_id: message.id, recipient_id: recipient.id}
          )
        end

        run_background_jobs!

        expect(sent_emails.size).to eq 5

        sent_emails.each do |email|
          email.text_part.body.should include body
          email.html_part.body.should include body
          email.subject.should == "✔ [RaceTeam] #{conversation.subject}"
        end

      end
    end
  end

end
