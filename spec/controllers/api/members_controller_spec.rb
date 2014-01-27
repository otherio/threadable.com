require 'spec_helper'

describe Api::MembersController do

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
            expect(response.body).to eq serialize(:members, raceteam.members.all).to_json
          end

          context "with a valid group id" do
            let(:electronics) { raceteam.groups.find_by_email_address_tag('electronics') }

            it "renders all the members of the group as json" do
              xhr :get, :index, format: :json, organization_id: raceteam.slug, group_id: electronics.email_address_tag
              expect(response).to be_ok
              expect(response.body).to eq serialize(:members, electronics.members.all).to_json
            end
          end

          context "with an invalid or missing group id" do
            it 'renders not found' do
              xhr :get, :index, format: :json, organization_id: raceteam.slug, group_id: 'foobar'
              expect(response.status).to eq 404
              expect(response.body).to eq '{"error":"Not Found"}'
            end
          end
        end
        context 'of an organization that the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: sfhealth.slug
            expect(response.status).to eq 404
            expect(response.body).to eq '{"error":"Not Found"}'
          end
        end
        context 'of an organization that does not exist' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: 'foobar'
            expect(response.status).to eq 404
            expect(response.body).to eq '{"error":"Not Found"}'
          end
        end
      end
    end

    describe '#create' do
      context "when given a valid organization id" do
        it "renders the newly invited member as json, and creates the member" do
          member_count = raceteam.members.all.length
          xhr :post, :create, format: :json, organization_id: raceteam.slug, member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 201
          member = raceteam.members.all.find{|m| m.email_address == 'john@varvatos.com'}
          expect(member).to be_present
          expect(response.body).to eq serialize(:members, member).to_json
          expect(raceteam.members.all.length).to eq member_count + 1
        end
      end
      context "when given an organization id of an organization that does not exist" do
        it 'renders not found' do
          xhr :post, :create, format: :json, organization_id: 'foobar', member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"Not Found"}'
        end
      end
      context 'when given an organization id of an organization that the current user is not in' do
        it 'renders not found' do
          xhr :post, :create, format: :json, organization_id: sfhealth.slug, member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"Not Found"}'
        end
      end
      context 'when given no organization id' do
        it 'renders not found' do
          xhr :post, :create, format: :json, member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"Not Found"}'
        end
      end
    end
  end


end
