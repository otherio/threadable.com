require 'spec_helper'

describe ConversationMessageCreator do

  let(:project) { Project.where(name: "UCSD Electric Racing").includes(:members).first! }
  let(:conversation) { project.conversations.first }
  let(:user) { project.members.first }

  def self.test!
    it "should create a new conversation message and dispatch it for emailing" do
      message_dispatcher = double(:message_dispatcher)
      # MessageDispatch.should_receive(:new).with(kind_of(Message), email_sender: true).and_return(message_dispatcher)
      SendConversationMessageWorker.should_receive(:enqueue) #.with(message_id: 1)
      # message_dispatcher.should_receive(:enqueue)

      message = ConversationMessageCreator.call(user, conversation, message_attributes)
      message.should be_a Message
      message.should be_persisted
      message.subject.should        == message_attributes[:subject]
      message.body_html.should      == message_attributes[:body]
      message.stripped_html.should  == message_attributes[:body]
      message.body_plain.should     == strip_html(message_attributes[:body])
      message.stripped_plain.should == strip_html(message_attributes[:body])
      message.user.should           == user
      message.conversation.should   == conversation

      attachment_attributes = message.attachments.map{|attachment|
        attachment.attributes.slice("url","filename","mimetype","size","writeable")
      }.to_set

      expect(attachment_attributes).to eq(Array(message_attributes["attachments"]).to_set)
    end
  end

  def strip_html(html)
    HTMLEntities.new.decode Sanitize.clean(html.gsub(%r{<br/?>}, "\n"))
  end


  context "when given attachments" do
    def message_attributes
      {
        "subject" => "hey fellas",
        "body" => "Hey, <i>Anyone</i> want some <strong>cake</strong>?",
        "attachments"=> [
          {
            "url"=>"https://www.filepicker.io/api/file/g88HcWEkSN68EwKKIBTm",
            "filename"=>"2013-06-14 13.05.02.jpg",
            "mimetype"=>"image/jpeg",
            "size"=> 1830234,
            "writeable"=>true,
          },{
            "url"=>"https://www.filepicker.io/api/file/SavvNKdkTI2fDlyNKbab",
            "filename"=>"4816514863_20dc8027c6_o.jpg",
            "mimetype"=>"image/jpeg",
            "size"=> 3733625,
            "writeable"=>true,
          }
        ]
      }.with_indifferent_access
    end
    test!
  end

  context "when given no attachments" do
    def message_attributes
      {
        "subject" => "hey fellas",
        "body" => "Hey, <i>Anyone</i> want some <strong>cake</strong>?",
      }.with_indifferent_access
    end
    test!
  end
end
