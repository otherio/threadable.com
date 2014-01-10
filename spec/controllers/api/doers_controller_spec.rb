require 'spec_helper'

describe Api::DoersController do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json, organization_id: 1, task_id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end
  end

  when_signed_in_as 'bob@ucsd.example.com' do

    let(:raceteam){ covered.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ covered.organizations.find_by_slug! 'sfhealth' }
    let(:task)    { raceteam.tasks.find_by_slug('layup-body-carbon')}

    # get /api/:organization/tasks/:task/doers
    describe 'index' do
      context 'when given an organization id' do
        context 'of an organization that the current user is in' do

          context "with a valid task id" do
            it "renders all the doers of the given organization/task as json" do
              xhr :get, :index, format: :json, organization_id: raceteam.slug, task_id: task.slug
              expect(response).to be_ok
              expect(response.body).to eq Api::MembersSerializer[task.doers.all].to_json
            end
          end

          context "with a task that does not exist or is invalid" do
            it 'renders not found' do
              xhr :get, :index, format: :json, organization_id: raceteam.slug, task_id: 'foobar'
              expect(response.status).to eq 404
              expect(response.body).to be_blank
            end
          end
        end
        context 'of an organization that the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: sfhealth.slug, task_id: 'foobar'
            expect(response.status).to eq 404
            expect(response.body).to be_blank
          end
        end
        context 'of an organization that does not exist current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: 'foobar', task_id: 'baz'
            expect(response.status).to eq 404
            expect(response.body).to be_blank
          end
        end
      end
    end
  end


end
