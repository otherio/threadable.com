require 'spec_helper'

describe Task::DoersController do

  before{ sign_in! find_user_by_email_address('bob@ucsd.covered.io') }

  let(:project){ current_user.projects.find_by_slug! 'raceteam' }
  let(:task   ){ project.tasks.find_by_slug! 'layup-body-carbon' }

  describe "POST create" do

    let(:user_id){ member.user_id }

    def params
      {
        project_id: project.to_param,
        task_id: task.to_param,
        user_id: user_id,
      }
    end

    def create! params={}
      post :create, self.params.merge(params)
    end

    context "when the user is a member of the project and not a doer of the task" do
      let(:member) { project.members.find_by_user_slug!('alice-neilson') }

      it "adds the user as a member to the task and redirects back to the task show page" do
        expect{ expect{ create! }.to change{ task.events.count }.by(1) }.to change{ task.doers.count }.by(1)
        expect(task.events.newest.as_json).to eq(
          type:     'added doer',
          actor_id: current_user.id,
          doer_id:  member.id,
          task_id:  task.id,
        )
        expect(response).to redirect_to project_conversation_url(project, task)
      end

      context "when format is json" do
        it "returns the member as json" do
          create!(format: :json)
          expect(response.response_code).to eq 201
          expect(response.body).to eq member.to_json
        end
      end
    end

    context "when the user doesn't exist" do
      let(:user_id){ 2837283718 }
      it "raises a not found error" do
        expect{ create! }.to raise_error(Covered::RecordNotFound)
      end
    end

    context "when the user is not a member of the project" do
      let(:user_id) { find_user_by_email_address('lilith@sfhealth.example.com').id }
      it "raises a not found error" do
        expect{ create! }.to raise_error(Covered::RecordNotFound)
      end
    end

    context "when the user is already a doer of this task" do
      let(:member){ project.members.find_by_user_slug!('tom-canver') }
      it "it looks as if you've added them" do
        expect{ expect{ create! }.to change{ task.events.count }.by(0) }.to change{ task.doers.count }.by(0)
        expect(response).to redirect_to project_conversation_url(project, task)
      end
      context "when format is json" do
        it "returns the member as json" do
          create!(format: :json)
          expect(response.response_code).to eq 201
          expect(response.body).to eq member.to_json
        end
      end
    end

  end

  describe "DELETE destroy" do

    let(:user_id){ member.user_id }

    def params
      {
        project_id: project.to_param,
        task_id: task.to_param,
        id: user_id,
      }
    end

    def destroy! params={}
      delete :destroy, self.params.merge(params)
    end

    context "when the user is a member of the project and a doer of the task" do
      let(:member){ project.members.find_by_user_slug!('tom-canver') }

      it "removes the user from the task's doers and redirects back to the task show page" do
        expect{ expect{ destroy! }.to change{ task.events.count }.by(1) }.to change{ task.doers.count }.by(-1)
        expect(task.events.newest.as_json).to eq(
          type:     'removed doer',
          actor_id: current_user.id,
          doer_id:  member.id,
          task_id:  task.id,
        )
        expect(response).to redirect_to project_conversation_url(project, task)
      end

      context "when format is json" do
        it "returns the member as json" do
          destroy!(format: :json)
          expect(response).to be_ok
          expect(response.body).to eq member.to_json
        end
      end
    end

    context "when the user doesn't exist" do
      let(:user_id){ 2837283718 }
      it "raises a not found error" do
        expect{ destroy! }.to raise_error(Covered::RecordNotFound)
      end
    end

    context "when the user is not a member of the project" do
      let(:user_id) { find_user_by_email_address('lilith@sfhealth.example.com').id }
      it "raises a not found error" do
        expect{ destroy! }.to raise_error(Covered::RecordNotFound)
      end
    end

    context "when the user is not a doer of this task" do
      let(:member) { project.members.find_by_user_slug!('alice-neilson') }
      it "it looks as if you've removed them" do
        expect{ expect{ destroy! }.to change{ task.events.count }.by(0) }.to change{ task.doers.count }.by(0)
        expect(response).to redirect_to project_conversation_url(project, task)
      end
      context "when format is json" do
        it "returns the member as json" do
          destroy!(format: :json)
          expect(response.response_code).to eq 200
          expect(response.body).to eq member.to_json
        end
      end
    end

  end

end
