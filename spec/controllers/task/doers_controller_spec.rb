require 'spec_helper'

describe Task::DoersController do

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
    return valid_params.merge({format: 'json'})
  end


  describe "POST create" do
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

  describe "DELETE destroy" do
    let(:doer) { create(:user) }
    let(:task) { project.tasks.create! valid_attributes }

    before do
      project.members << doer
      task.doers << doer
    end

    context "with valid params" do
      subject { delete :destroy, valid_params.merge( {:task_id => task.to_param, :id => doer.id} ) }

      it "adds a doer" do
        expect { subject }.to change(task.doers, :count).by(-1)
      end

      it "redirects back to the task" do
        subject
        response.should redirect_to project_conversation_url(project, Conversation.first)
      end

      context "when called with xhr" do
        subject { xhr :delete, :destroy, xhr_valid_params.merge( {:task_id => task.to_param, :id => doer.id} ) }
        it "returns :deleted" do
          subject
          response.response_code.should == 204
        end
      end
    end

    context "with a user who doesn't exist" do
      subject { delete :destroy, valid_params.merge( {:task_id => task.to_param, :id => 12345} ) }

      it "raises a not found error" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with a user who isn't part of the project" do
      let(:non_member_doer) { create(:user) }
      subject { delete :destroy, valid_params.merge( {:task_id => task.to_param, :id => non_member_doer.id} ) }

      it "raises a not found error" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    context "with a user who isn't a doer of that task" do
      let(:non_task_doer) { create(:user) }

      before do
        project.members << non_task_doer
      end

      subject { delete :destroy, valid_params.merge( {:task_id => task.to_param, :id => non_task_doer.id} ) }

      it "raises a not found error" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

end
