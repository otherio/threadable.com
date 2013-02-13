require 'spec_helper'

describe ConversationsController do

  let!(:current_user){ create(:user) }
  let!(:project){ create(:project) }

  before(:each) do
    project.members << current_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in current_user
  end

  # This should return the minimal set of attributes required to create a valid
  # Conversation. As you add validations to Conversation, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      "subject" => "how are we going to build this thing?",
    }
  end

  def valid_params
    {
      project_id: project.to_param
    }
  end

  def xhr_valid_params
    return valid_params.merge({format: 'json'})
  end

  describe "GET index" do
    it "assigns all conversations as @conversations" do
      conversation = project.conversations.create! valid_attributes
      get :index, valid_params
      assigns(:conversations).should eq([conversation])
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

    context "with a regular conversation" do
      subject { get :show, valid_params.merge(:id => conversation.to_param) }
      let!(:conversation) { project.conversations.create! valid_attributes }
      let(:message) { create(:message, conversation: conversation) }

      it "assigns the requested conversation as @conversation" do
        subject
        assigns(:conversation).should eq(conversation)
      end
    end

    context "with a task" do
      subject { get :show, valid_params.merge(:id => task.to_param) }
      let(:task) { project.tasks.create! valid_attributes }
      let(:doer) { create(:user) }
      let(:message) { create(:message, task: task) }

      before do
        task.doers << doer
      end

      it "has access to the doers" do
        subject
        assigns(:conversation).doers.should == [doer]
      end
    end

  end

  describe "POST create" do
    def valid_attributes
      super.merge(
        "messages" => {
          "body" => "I think we should use wood.",
        }
      )
    end

    describe "with valid params" do
      it "creates a new Conversation, assigns a newly created conversation as @conversation, and redirects to the created conversation" do
        expect {
          post :create, valid_params.merge(:conversation => valid_attributes)
        }.to change(Conversation, :count).by(1)
        assigns(:conversation).should be_a(Conversation)
        assigns(:conversation).should be_persisted
        response.should redirect_to project_conversation_url(project, project.conversations.first)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved conversation as @conversation, and re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        post :create, valid_params.merge(:conversation => { "subject" => "invalid value" })
        assigns(:conversation).should be_a_new(Conversation)
        response.should render_template("new")
      end
    end
  end


  describe "PUT update" do
    let!(:conversation){ Conversation.create!(valid_attributes.merge(project:project)) }

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
        put :update, valid_params.merge(:id => conversation.to_param, :conversation => valid_attributes)
        assigns(:conversation).should eq(conversation)
      end

      it "redirects to the conversation" do
        put :update, valid_params.merge(:id => conversation.to_param, :conversation => valid_attributes)
        response.should redirect_to project_conversation_url(project, conversation)
      end
    end

    describe "with invalid params" do
      it "assigns the conversation as @conversation" do
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        put :update, valid_params.update(:id => conversation.to_param, :conversation => {  })
        assigns(:conversation).should eq(conversation)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        put :update, valid_params.update(:id => conversation.to_param, :conversation => {  })
        response.should redirect_to project_conversation_url(project, conversation)
      end
    end
  end

end
