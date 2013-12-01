require 'spec_helper'

describe "Task doers" do

  when_not_signed_in do

    describe 'adding a doer' do
      it 'should redirect to a sign in page' do
        post '/raceteam/tasks/layup-body-carbon/doers', user_id: 1234
        expect(response).to be_redirect
      end
    end

    describe 'removing a doer' do
      it 'should redirect to a sign in page' do
        delete '/raceteam/tasks/layup-body-carbon/doers/1234'
        expect(response).to be_redirect
      end
    end

  end

  when_signed_in_as 'tom@ucsd.covered.io' do

    let(:project){ current_user.projects.find_by_slug! 'raceteam'    }
    let(:task)   { project.tasks.find_by_slug! 'layup-body-carbon'   }
    let(:tom)    { project.members.find_by_user_slug! 'tom-canver'   } # is a doer
    let(:bob)    { project.members.find_by_user_slug! 'bob-cauchois' } # is not a doer

    describe 'adding a doer' do
      it 'should add the doer and redirect to the task show page' do
        expect(task.doers).to_not include bob
        post '/raceteam/tasks/layup-body-carbon/doers', user_id: bob.user_id
        expect(response).to redirect_to project_conversation_url('raceteam', 'layup-body-carbon')
        expect(task.doers).to include bob
      end
      context 'when the given user id is for a user that is already a doer' do
        it 'should redirect to the task show page' do
          expect(task.doers).to include tom
          post '/raceteam/tasks/layup-body-carbon/doers', user_id: tom.user_id
          expect(response).to redirect_to project_conversation_url('raceteam', 'layup-body-carbon')
          expect(task.doers).to include tom
        end
      end
    end

    describe 'removing a doer' do
      it 'should remove the doer and redirect to the task show page' do
        expect(task.doers).to include tom
        delete "/raceteam/tasks/layup-body-carbon/doers/#{tom.user_id}"
        expect(response).to redirect_to project_conversation_url('raceteam', 'layup-body-carbon')
        expect(task.doers).to_not include tom
      end
      context 'when the given user id is for a user that is already not a doer' do
        it 'should redirect to the task show page' do
          expect(task.doers).to_not include bob
        delete "/raceteam/tasks/layup-body-carbon/doers/#{bob.user_id}"
          expect(response).to redirect_to project_conversation_url('raceteam', 'layup-body-carbon')
          expect(task.doers).to_not include bob
        end
      end
    end

  end

end
