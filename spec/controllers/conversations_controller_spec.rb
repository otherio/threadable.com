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
        }
      }
    end

    describe "with valid params" do
      it "creates a new Conversation, assigns a newly created conversation as @conversation, and redirects to the created conversation" do
        expect {
          post :create, valid_params.merge(valid_create_params)
        }.to change(Conversation, :count).by(1)
        assigns(:conversation).should be_a(Conversation)
        assigns(:conversation).should be_persisted
        response.should redirect_to project_conversation_url(project, expected_conversation)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved conversation as @conversation, and re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        post :create, valid_params.merge(valid_create_params)
        assigns(:conversation).should be_a_new(Conversation)
        response.should render_template("new")
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
