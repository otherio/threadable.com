require 'spec_helper'

describe Api::TasksController do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json, organization_id: 1
        expect(response.status).to eq 401
      end
    end
  end

  when_signed_in_as 'bob@ucsd.example.com' do

    let(:raceteam){ covered.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ covered.organizations.find_by_slug! 'sfhealth' }
    let(:tasks) { }

    # get /api/organizations
    describe 'index' do
      context 'when given an organization id' do
        context 'of an organization that the current user is in' do
          it "renders all the tasks of the given organization as json" do
            xhr :get, :index, format: :json, organization_id: raceteam.slug
            expect(response).to be_ok
            expect(response.body).to eq serialize(:tasks, raceteam.tasks.all).to_json
          end

          # get /api/:organization_id/groups/:group_id/conversations
          context 'when given a valid group id' do
            let(:electronics) { raceteam.groups.find_by_email_address_tag('electronics') }
            it 'gets tasks scoped to the group' do
              xhr :get, :index, format: :json, organization_id: raceteam.slug, group_id: electronics.email_address_tag
              expect(response).to be_ok
              expect(response.body).to eq serialize(:tasks, electronics.tasks.all).to_json
            end
          end

          context 'when given an invalid or nonexistant group id' do
            it 'renders not found' do
              xhr :get, :index, format: :json, organization_id: raceteam.slug, group_id: 'foobar'
              expect(response.status).to eq 404
            end
          end
        end
        context 'of an organization that the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: sfhealth.slug
            expect(response.status).to eq 404
          end
        end
        context 'of an organization that does not exist current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: 'foobar'
            expect(response.status).to eq 404
          end
        end
      end
    end
  end


end
