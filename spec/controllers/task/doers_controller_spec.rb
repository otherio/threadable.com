require 'spec_helper'

describe Task::DoersController do

  when_not_signed_in do

    describe 'PUT :create' do
      it 'should redirect to a sign in page' do
        post :add, organization_id: 'foo', task_id: 'bar'
        expect(response).to be_redirect
      end
    end

    describe 'DELETE :destroy' do
      it 'should redirect to a sign in page' do
        delete :remove, organization_id: 'foo', task_id: 'bar', user_id: 44
        expect(response).to be_redirect
      end
    end

  end

  when_signed_in_as 'tom@ucsd.covered.io' do

    let(:organization){ double :organization, tasks: double(:tasks), members: double(:members), to_param: 'raceteam' }
    let(:task){ double :task, doers: double(:doers), to_param: 'layup-body-carbon' }
    let(:user_id){ 489 }
    let(:member){ double :member, name: 'Bobby Fisher', to_json: "MEMBER AS JSON" }

    before do
      expect(current_user.organizations).to receive(:find_by_slug!).with('raceteam').and_return(organization)
      expect(organization.tasks).to receive(:find_by_slug!).with('layup-body-carbon').and_return(task)
      expect(organization.members).to receive(:find_by_user_id!).with(user_id).and_return(member)
    end

    describe 'PUT :create' do
      before{ expect(task.doers).to receive(:add).with(member) }
      it 'should add the user as a doer of the task' do
        post :add, organization_id: 'raceteam', task_id: 'layup-body-carbon', user_id: user_id
        expect(response).to redirect_to organization_conversation_url('raceteam', 'layup-body-carbon')
      end
      context "when format is json" do
        it 'should remove the user as a doer of the task' do
          post :add, organization_id: 'raceteam', task_id: 'layup-body-carbon', user_id: user_id, format: :json
          expect(response.status).to eq 201
          expect(response.body).to eq "MEMBER AS JSON"
        end
      end
    end

    describe 'DELETE :destroy' do
      before{ expect(task.doers).to receive(:remove).with(member) }
      it 'should remove the user as a doer of the task' do
        delete :remove, organization_id: 'raceteam', task_id: 'layup-body-carbon', user_id: user_id
        expect(response).to redirect_to organization_conversation_url('raceteam', 'layup-body-carbon')
      end
      context "when format is json" do
        it 'should remove the user as a doer of the task' do
          delete :remove, organization_id: 'raceteam', task_id: 'layup-body-carbon', user_id: user_id, format: :json
          expect(response.status).to eq 200
          expect(response.body).to eq "MEMBER AS JSON"
        end
      end
    end

  end

end
