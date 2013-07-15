require 'spec_helper'

describe ConversationsController do

  let(:project){ Project.first }
  let(:current_user){ project.members.first }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in current_user
  end


  def valid_attributes
    {
      "subject" => "how are we going to build this thing?",
      "creator" => current_user,
    }
  end

  def valid_params
    {
      project_id: project.to_param
    }
  end

  def xhr_valid_params
    valid_params.merge({format: 'json'})
  end

  def expected_conversation
    project.conversations.find_by_subject(valid_attributes["subject"])
  end

  describe "GET index" do
    it "assigns all conversations as @conversations" do
      conversation = project.conversations.create! valid_attributes
      get :index, valid_params
      assigns(:conversations).should eq(project.conversations)
    end
  end

  describe "GET new" do
    it "assigns a new conversation as @conversation" do
      get :new, valid_params
      assigns(:conversation).should be_a(Conversation)
      assigns(:conversation).should_not be_persisted
    end
  end

  describe "GET show" do

    # context "with a regular conversation" do
    subject { get :show, valid_params.merge(:id => conversation.to_param) }
    let!(:conversation) { project.conversations.create! valid_attributes }
    let(:message) { create(:message, conversation: conversation) }

    it "assigns the requested conversation as @conversation" do
      subject
      assigns(:conversation).should eq(conversation)
    end
  end

  describe "POST create" do

    def valid_create_params
      {
        "message" => {
          "subject" => valid_attributes["subject"],
          "body"    => "I think we should use wood.",
          "attachments"=> [
            {
              "url"=>"https://www.filepicker.io/api/file/g88HcWEkSN68EwKKIBTm",
              "filename"=>"2013-06-14 13.05.02.jpg",
              "mimetype"=>"image/jpeg",
              "size"=>"1830234",
              "writeable"=>"true",
            },{
              "url"=>"https://www.filepicker.io/api/file/SavvNKdkTI2fDlyNKbab",
              "filename"=>"4816514863_20dc8027c6_o.jpg",
              "mimetype"=>"image/jpeg",
              "size"=>"3733625",
              "writeable"=>"true",
            }
          ]
        }
      }
    end

    let(:conversation){ double(:conversation, :persisted? => conversation_saves) }

    before do
      message_attributes = valid_create_params["message"]

      conversations = double(:conversations)
      Project.any_instance.should_receive(:conversations).and_return(conversations)

      conversation_attributes = {
        creator: current_user,
        subject: message_attributes.delete("subject"),
      }
      conversations.should_receive(:new).with(conversation_attributes).and_return(conversation)
      conversation.should_receive(:save).and_return(conversation_saves)

      message = double(:message, :persisted? => message_saves)

      if conversation_saves
        ConversationMessageCreator.should_receive(:call).
          with(current_user, conversation, message_attributes).
          and_return(message)
      else
        ConversationMessageCreator.should_not_receive(:call)
      end
    end

    [true, false].each do |conversation_saves|

      context conversation_saves ? "when the conversation saves" : "when the conversation fails to save" do
        let(:conversation_saves){ message_saves && conversation_saves }

        [true, false].each do |message_saves|

          context message_saves ? "and the message saves" : "but the message fails to save" do
            let(:message_saves){ message_saves }

            it "creates a new Conversation, assigns a newly created conversation as @conversation, and redirects to the created conversation" do
              post :create, valid_params.merge(valid_create_params)
              assigns(:conversation).should eq(conversation)
              if conversation_saves && message_saves
                response.should redirect_to project_conversation_url(project, conversation)
              else
                response.should render_template("new")
              end
            end

          end

        end

      end

    end

  end


  describe "PUT update" do
    let!(:conversation){ Conversation.create!(valid_attributes.merge(project:project, creator: current_user)) }

    def valid_update_params
      {
        "subject" => valid_attributes["subject"],
      }
    end

    describe "with valid params" do
      it "updates the requested conversation" do
        now = Time.now
        Time.stub(:now).and_return(now)
        Conversation.any_instance.should_receive(:update_attributes).with({
          "subject" => "How aren't we going to build this thing?",
          "done_at" => Time.now,
        })
        put :update, valid_params.merge(:id => conversation.to_param, :conversation => {
          "subject" => "How aren't we going to build this thing?",
          "done" => "true",
        })
      end

      it "assigns the requested conversation as @conversation" do
        put :update, valid_params.merge(:id => conversation.to_param, :conversation => valid_update_params)
        assigns(:conversation).should eq(conversation)
      end

      it "redirects to the conversation" do
        put :update, valid_params.merge(:id => conversation.to_param, :conversation => valid_update_params)
        response.should redirect_to project_conversation_url(project, conversation)
      end
    end

    describe "with invalid params" do
      def invalid_params
        {
          id: conversation.to_param,
          conversation: {
            subject: ""
          }
        }
      end

      it "assigns the conversation as @conversation" do
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        put :update, valid_params.update(invalid_params)
        assigns(:conversation).should eq(conversation)
      end

      it "redirect to the project conversation page" do
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        put :update, valid_params.update(invalid_params)
        response.should redirect_to project_conversation_url(project, conversation)
      end
    end
  end

end
