require 'spec_helper'

describe MessagesController do

  let(:project){ Project.first }
  let(:current_user){ project.members.first }
  let!(:conversation) { FactoryGirl.create(:conversation, project: project) }

  let(:valid_attributes) do
    from_factory = message.attributes.dup
    from_factory["body"] = from_factory.delete("body_html")
    from_factory
  end

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in current_user
  end

  def valid_params
    {
      conversation_id: conversation.slug,
      project_id: project.slug
    }
  end

  describe "POST create" do
    let(:message) { FactoryGirl.build(:message, subject: nil, conversation: conversation) }

    def request!
      xhr :post, :create, valid_params.merge(message: valid_attributes)
    end

    it "creates a new Message" do
      expect{ request! }.to change(conversation.messages, :count).by(1)
      response.status.should == 201
    end

    it "sets the subject" do
      request!
      assigns(:message).subject.should == conversation.subject
    end

    it "has no parent message" do
      request!
      assigns(:message).parent_message.should be_nil
    end

    it "has a body_plain and a stripped_plain" do
      request!
      assigns(:message).body_html.should == message.body_html
      assigns(:message).stripped_html.should == message.body_html
      assigns(:message).body_plain.should == message.body_plain
      assigns(:message).stripped_plain.should == message.body_plain
    end

    context "with special characters in the message" do
      let(:message) do
        FactoryGirl.build(:message,
          subject: nil,
          conversation: conversation,
          body_plain: 'foo & bar',
          body_html: '<b>foo &amp; bar</b>'
        )
      end

      it "transforms entities for the text part" do
        request!
        assigns(:message).body_html.should == message.body_html
        assigns(:message).body_plain.should == message.body_plain
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
