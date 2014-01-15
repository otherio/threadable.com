require 'spec_helper'

describe Api::MembersController do

  # when_not_signed_in do
  #   describe 'index' do
  #     it 'renders unauthorized' do
  #       xhr :get, :index, format: :json, organization_id: 1, task_id: 1
  #       expect(response.status).to eq 401
  #       expect(response.body).to be_blank
  #     end
  #   end
  # end

  # when_signed_in_as 'bob@ucsd.example.com' do

  #   let(:raceteam){ covered.organizations.find_by_slug! 'raceteam' }
  #   let(:sfhealth){ covered.organizations.find_by_slug! 'sfhealth' }

  #   # get /api/:organization/tasks/:task/members
  #   describe 'index' do
  #     context 'when given an organization id' do

  #       context 'of an organization that the current user is in' do
  #         it "renders all the members of the organization as json" do
  #           xhr :get, :index, format: :json, organization_id: raceteam.slug
  #           expect(response).to be_ok
  #           expect(response.body).to eq Api::MembersSerializer[raceteam.members.all].to_json
  #         end

  #         context "with a valid group id" do
  #           let(:electronics) { raceteam.groups.find_by_email_address_tag('electronics') }

  #           it "renders all the members of the group as json" do
  #             xhr :get, :index, format: :json, organization_id: raceteam.slug, group_id: electronics.email_address_tag
  #             expect(response).to be_ok
  #             expect(response.body).to eq Api::MembersSerializer[electronics.members.all].to_json
  #           end
  #         end

  #         context "with an invalid or missing group id" do
  #           it 'renders not found' do
  #             xhr :get, :index, format: :json, organization_id: raceteam.slug, group_id: 'foobar'
  #             expect(response.status).to eq 404
  #             expect(response.body).to be_blank
  #           end
  #         end
  #       end
  #       context 'of an organization that the current user is not in' do
  #         it 'renders not found' do
  #           xhr :get, :index, format: :json, organization_id: sfhealth.slug
  #           expect(response.status).to eq 404
  #           expect(response.body).to be_blank
  #         end
  #       end
  #       context 'of an organization that does not exist current user is not in' do
  #         it 'renders not found' do
  #           xhr :get, :index, format: :json, organization_id: 'foobar'
  #           expect(response.status).to eq 404
  #           expect(response.body).to be_blank
  #         end
  #       end
  #     end
  #   end
  # end


end
