require 'spec_helper'

describe Task::DoersController do

  let!(:current_user){ create(:user) }
  let!(:project){ create(:project) }

  before(:each) do
    project.members << current_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in current_user
  end

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


  describe "POST add_doer" do
    let(:doer) { create(:user) }
    let(:task) { project.tasks.create! valid_attributes }

    before do
      project.members << doer
    end

    context "with valid params" do
      subject { post :create, valid_params.merge( {:task_id => task.to_param, :doer_id => doer.id} ) }

      it "adds a doer" do
        expect { subject }.to change(task.doers, :count).by(1)
      end

      it "redirects back to the task" do
        subject
        response.should redirect_to project_conversation_url(project, Conversation.first)
      end

      context "when called with xhr" do
        subject { xhr :post, :create, xhr_valid_params.merge( {:task_id => task.to_param, :doer_id => doer.id} ) }
        it "returns :created" do
          subject
          response.response_code.should == 201
        end
      end
    end

    context "with a user who doesn't exist" do
      subject { post :create, valid_params.merge( {:task_id => task.to_param, :doer_id => 12345} ) }

      it "raises a not found error" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with a user who isn't part of the project" do
      let(:non_member_doer) { create(:user) }
      subject { post :create, valid_params.merge( {:task_id => task.to_param, :doer_id => non_member_doer.id} ) }

      it "raises a not found error" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET 'destroy'" do
    it "returns http success" do
      pending
      get 'destroy'
      response.should be_success
    end
  end

end
