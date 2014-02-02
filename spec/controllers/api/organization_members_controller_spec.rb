require 'spec_helper'

describe Api::OrganizationMembersController do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json, organization_id: 1, task_id: 1
        expect(response.status).to eq 401
        expect(response.body).to eq '{"error":"Unauthorized"}'
      end
    end
  end

  when_signed_in_as 'bob@ucsd.example.com' do

    let(:raceteam){ covered.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ covered.organizations.find_by_slug! 'sfhealth' }

    # get /api/:organization/tasks/:task/members
    describe 'index' do
      context 'when given an organization id' do

        context 'of an organization that the current user is in' do
          it "renders all the members of the organization as json" do
            xhr :get, :index, format: :json, organization_id: raceteam.slug
            expect(response).to be_ok
            expect(response.body).to eq serialize(:organization_members, raceteam.members.all).to_json
          end
        end
        context 'of an organization that the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: sfhealth.slug
            expect(response.status).to eq 404
            expect(response.body).to eq '{"error":"unable to find organization with slug \"sfhealth\""}'
          end
        end
        context 'of an organization that does not exist' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: 'foobar'
            expect(response.status).to eq 404
            expect(response.body).to eq '{"error":"unable to find organization with slug \"foobar\""}'
          end
        end
      end
    end

    describe '#create' do
      context "when given a valid organization id" do
        it "renders the newly invited member as json, and creates the member" do
          member_count = raceteam.members.all.length
          xhr :post, :create, format: :json, organization_id: raceteam.slug, organization_member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 201
          member = raceteam.members.all.find{|m| m.email_address == 'john@varvatos.com'}
          expect(member).to be_present
          expect(response.body).to eq serialize(:organization_members, member).to_json
          expect(raceteam.members.all.length).to eq member_count + 1
        end
      end
      context "when given an organization id of an organization that does not exist" do
        it 'renders not found' do
          xhr :post, :create, format: :json, organization_id: 'foobar', organization_member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find organization with slug \"foobar\""}'
        end
      end
      context 'when given an organization id of an organization that the current user is not in' do
        it 'renders not found' do
          xhr :post, :create, format: :json, organization_id: sfhealth.slug, organization_member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find organization with slug \"sfhealth\""}'
        end
      end
      context 'when given no organization id' do
        it 'renders not found' do
          xhr :post, :create, format: :json, organization_member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find organization with slug nil"}'
        end
      end
    end
  end


end
