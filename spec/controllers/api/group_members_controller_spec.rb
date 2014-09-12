require 'spec_helper'

describe Api::GroupMembersController, :type => :controller do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json, organization_id: 1, group_id: 1
        expect(response.status).to eq 401
      end
    end
    describe 'create' do
      it 'renders unauthorized' do
        xhr :post, :create, format: :json, organization_id: 1, group_id: 1
        expect(response.status).to eq 401
      end
    end
    describe 'destroy' do
      it 'renders unauthorized' do
        xhr :delete, :destroy, format: :json, organization_id: 1, group_id: 1, id: 1
        expect(response.status).to eq 401
      end
    end
    describe 'update' do
      it 'renders unauthorized' do
        xhr :patch, :update, format: :json, organization_id: 1, group_id: 1, id: 1
        expect(response.status).to eq 401
      end
    end
  end

  when_signed_in_as 'alice@ucsd.example.com' do

    let(:raceteam)   { threadable.organizations.find_by_slug! 'raceteam' }
    let(:graphic_design){ raceteam.groups.find_by_email_address_tag!('graphic-design') }

    # get /api/groups/:group_id/members
    describe 'index' do
      context 'when given a group id' do
        context 'of an group that the current user is in' do
          it "renders all the members of the given group as json" do
            xhr :get, :index, format: :json, organization_id: raceteam.slug, group_id: graphic_design.email_address_tag
            expect(response).to be_ok
            expect(response.body).to eq serialize(:group_members, graphic_design.members.all).to_json
          end
        end
        context 'of a group that does not exist' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: raceteam.slug, group_id: 'foobar'
            expect(response.status).to eq 404
          end
        end
      end
    end

    # patch /api/groups/:group_id/members
    describe 'update' do

      let(:alice){ raceteam.members.find_by_email_address!('alice@ucsd.example.com') }

      context 'when given a group member id' do
        it "updates the members delivery method and returns the member" do
          xhr :patch, :update, format: :json, id: 1, organization_id: raceteam.slug, group_id: graphic_design.email_address_tag, group_member: { user_id: alice.id, delivery_method: 'gets_in_summary' }
          expect(response).to be_ok
          member = graphic_design.members.find_by_user_id(alice.id)
          expect(member.delivery_method).to eq 'gets_in_summary'
          expect(response.body).to eq serialize(:group_members, member).to_json
        end
      end
    end
  end
end
