require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

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
      "subject" => Faker::Company.bs,
    }
  end

  def valid_params
    {
      project_id: project.to_param
    }
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
    it "assigns the requested conversation as @conversation" do
      conversation = project.conversations.create! valid_attributes
      get :show, valid_params.merge(:id => conversation.to_param)
      assigns(:conversation).should eq(conversation)
    end
  end

  describe "POST create" do
    def valid_attributes
      {
        "subject" => Faker::Company.bs,
        "messages" => {
          "body" => Faker::Company.bs,
        }
      }
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

  describe "POST add_doer" do
    let(:doer) { create(:user) }
    let(:task) { project.tasks.create! valid_attributes }

    context "with valid params" do
      it "adds a doer" do
        expect {
          post :add_doer, valid_params.merge(:task_id => task.to_param) #, {:doer_id => doer.id}
        }.to change(task.doers, :count).by(1)
      end

      it "redirects back to the task" do
        pending
        post :add_doer, valid_params.merge(:doer => doer)
        response.should redirect_to conversation_url(project, Conversation.first)
      end
    end

    context "with a user id that isn't part of the project" do
      it "returns a 404" do
        1.should == 0
      end
    end

  end


  describe "PUT mute" do
    # describe "with valid params" do
    #   it "updates the requested conversation" do
    #     conversation = project.conversations.create! valid_attributes
    #     # Assuming there are no other conversations in the database, this
    #     # specifies that the Conversation created on the previous line
    #     # receives the :update_attributes message with whatever params are
    #     # submitted in the request.
    #     Conversation.any_instance.should_receive(:update_attributes).with({ "subject" => "MyString" })
    #     put :update, valid_params.merge(:id => conversation.to_param, :conversation => { "subject" => "MyString" })
    #   end

    #   it "assigns the requested conversation as @conversation" do
    #     conversation = project.conversations.create! valid_attributes
    #     put :update, valid_params.merge(:id => conversation.to_param, :conversation => valid_attributes)
    #     assigns(:conversation).should eq(conversation)
    #   end

    #   it "redirects to the conversation" do
    #     conversation = project.conversations.create! valid_attributes
    #     put :update, valid_params.merge(:id => conversation.to_param, :conversation => valid_attributes)
    #     response.should redirect_to(conversation)
    #   end
    # end

    # describe "with invalid params" do
    #   it "assigns the conversation as @conversation" do
    #     conversation = project.conversations.create! valid_attributes
    #     # Trigger the behavior that occurs when invalid params are submitted
    #     Conversation.any_instance.stub(:save).and_return(false)
    #     put :update, valid_params.merge(:id => conversation.to_param, :conversation => { "subject" => "invalid value" })
    #     assigns(:conversation).should eq(conversation)
    #   end

    #   it "re-renders the 'edit' template" do
    #     conversation = project.conversations.create! valid_attributes
    #     # Trigger the behavior that occurs when invalid params are submitted
    #     Conversation.any_instance.stub(:save).and_return(false)
    #     put :update, valid_params.merge(:id => conversation.to_param, :conversation => { "subject" => "invalid value" })
    #     response.should render_template("edit")
    #   end
    # end
  end


end
