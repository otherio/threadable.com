require 'spec_helper'

describe MessagesController do

  let(:project){ Project.first }
  let(:current_user){ project.members.first }
  let!(:conversation) { FactoryGirl.create(:conversation, project: project) }

  def valid_attributes
    {
      "body" => "<b>hello</b><span>there people</span>",
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
    }
  end

  before(:each) do
    sign_in_as current_user
  end

  def valid_params
    {
      conversation_id: conversation.slug,
      project_id: project.slug
    }
  end

  describe "POST create" do

    def request!
      xhr :post, :create, valid_params.merge(message: valid_attributes)
    end

    it "creates a new Message" do
      expect{ request! }.to change(conversation.messages, :count).by(1)
      response.status.should == 201
      message = assigns(:message)
      expect(message.subject).to eq(conversation.subject)
      expect(message.parent_message).to be_nil
      expect(message.body_html).to      eq(valid_attributes["body"])
      expect(message.stripped_html).to  eq(valid_attributes["body"])
      expect(message.body_plain).to     eq("hellothere people")
      expect(message.stripped_plain).to eq("hellothere people")
      attachments = message.attachments.map do |attachment|
        attachment.attributes.slice(*%w{url filename mimetype size writeable})
      end
      expect(attachments).to eq(valid_attributes["attachments"])
    end

    context "with special characters in the message" do

      def valid_attributes
        super.merge("body" => '<b>foo &amp; bar</b>')
      end

      it "transforms entities for the text part" do
        request!
        message = assigns(:message)
        expect(message.body_html).to      eq(valid_attributes["body"])
        expect(message.stripped_html).to  eq(valid_attributes["body"])
        expect(message.body_plain).to     eq("foo & bar")
        expect(message.stripped_plain).to eq("foo & bar")
      end
    end

    context "with more than one message in the conversation" do
      let!(:first_message) { FactoryGirl.create(:message, conversation: conversation) }

      it "sets the parent message if present" do
        request!
        assigns(:message).parent_message.id.should == first_message.id
      end
    end

    context "sending emails" do
      before { SendConversationMessageWorker.any_instance.stub(:enqueue) }

      it "enqueues emails for members" do
        SendConversationMessageWorker.should_receive(:enqueue).at_least(:once)
        request!
      end
    end
  end

  describe "PUT update" do
    let(:message) { FactoryGirl.create(:message, subject: nil, conversation: conversation) }
    let(:message_params) { valid_attributes }

    def request!
      xhr :put, :update, valid_params.merge(id: message.id, message: message_params)
    end

    context "setting shareworthy and knowledge" do
      let(:message_params) { {shareworthy: true, knowledge: true} }
      it "marks the message correctly" do
        request!
        assigns(:message).shareworthy.should == true
        assigns(:message).knowledge.should == true
      end
    end

  end
end
