require 'spec_helper'

describe Covered::Messages::Create do

  let(:current_user){ find_user 'alice-neilson' }
  let(:project     ){ find_project 'raceteam' }
  let(:conversation){ project.conversations.first! }
  let(:subject     ){ "hey fellas" }
  let(:body        ){ "Hey, <br/><br/><i>Anyone</i> want some <strong>cake</strong>?" }

  def message_attributes
    {
      subject: subject,
      body: body,
    }
  end

  def perform!
    described_class.call(
      resource:          covered.messages,
      project_slug:      'raceteam',
      conversation_slug: 'layup-body-carbon',
      message_attributes: message_attributes,
    )
  end

  it "should create a conversation message" do
    message = perform!
    expect( message                ).to be_persisted
    expect( message                ).to be_a Covered::Message
    expect( message.project        ).to eq project
    expect( message.conversation   ).to eq conversation
    expect( message.creator        ).to eq covered.current_user
    expect( message.from           ).to eq covered.current_user.email
    expect( message.subject        ).to eq subject
    expect( message.body_html      ).to eq body
    expect( message.stripped_html  ).to eq body
    expect( message.body_plain     ).to eq "Hey, \n\nAnyone want some cake?"
    expect( message.stripped_plain ).to eq "Hey, \n\nAnyone want some cake?"
    expect( message.attachments    ).to eq []
  end

  context "with attachments" do

    def message_attributes
      super.merge(
        attachments: [
          {
            url:       "https://www.filepicker.io/api/file/g88HcWEkSN68EwKKIBTm",
            filename:  "2013-06-14 13.05.02.jpg",
            mimetype:  "image/jpeg",
            size:      1830234,
            writeable: true,
          },{
            url:       "https://www.filepicker.io/api/file/SavvNKdkTI2fDlyNKbab",
            filename:  "4816514863_20dc8027c6_o.jpg",
            mimetype:  "image/jpeg",
            size:      3733625,
            writeable: true,
          }
        ]
      )
    end

    it "should create attachments" do
      message = perform!

      attachment_attributes = message.attachments.map{|attachment|
        {
          url:       attachment.url,
          filename:  attachment.filename,
          mimetype:  attachment.mimetype,
          size:      attachment.size,
          writeable: attachment.writeable,
        }
      }.to_set

      expect(attachment_attributes).to eq(Array(message_attributes[:attachments]).to_set)
    end

  end

  context "when given no subject" do
    def message_attributes
      super.slice!(:subject)
    end
    it "should use the conversation's subject" do
      message = perform!
      expect(message.subject).to eq conversation.subject
    end
  end

  context "when not signed in " do
    let(:project     ){ Covered::Project.where(slug: 'sfhealth').first! }
    let(:conversation){ project.conversations.first! }
    let(:current_user){ nil }
    it "should raise a Covered::AuthorizationError" do
      expect{ perform! }.to raise_error Covered::AuthorizationError
    end

  end

end
