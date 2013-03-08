require 'spec_helper'

describe MessagesController do

  let(:project){ Project.first }
  let(:current_user){ project.members.first }
  let!(:conversation) { FactoryGirl.create(:conversation, project: project) }

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
    let(:valid_attributes) do
      message.attributes.reject{|key, _| !Message.accessible_attributes.include?(key) }
    end

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
end

