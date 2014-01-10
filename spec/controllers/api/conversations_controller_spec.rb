require 'spec_helper'

describe Api::ConversationsController do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json, organization_id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end
    describe 'create' do
      it 'renders unauthorized' do
        xhr :post, :create, format: :json, organization_id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end
    describe 'show' do
      it 'renders unauthorized' do
        xhr :get, :show, format: :json, organization_id: 1, id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end
    describe 'update' do
      it 'renders unauthorized' do
        xhr :patch, :update, format: :json, organization_id: 1, id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end
  end

  when_signed_in_as 'bob@ucsd.example.com' do

    let(:raceteam){ covered.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ covered.organizations.find_by_slug! 'sfhealth' }
    let(:conversations) { }

    # get /api/:organization_id/conversations
    describe 'index' do
      context 'when given an organization id' do
        context 'of an organization that the current user is in' do
          it "renders all the conversations of the given organization as json" do
            xhr :get, :index, format: :json, organization_id: raceteam.slug
            expect(response).to be_ok
            expect(response.body).to eq Api::ConversationsSerializer[raceteam.conversations.all].to_json
          end

          # get /api/:organization_id/groups/:group_id/conversations
          context 'when given a valid group id' do
            let(:electronics) { raceteam.groups.find_by_email_address_tag('electronics') }
            it 'gets conversations scoped to the group' do
              xhr :get, :index, format: :json, organization_id: raceteam.slug, group_id: electronics.email_address_tag
              expect(response).to be_ok
              expect(response.body).to eq Api::ConversationsSerializer[electronics.conversations.all].to_json
            end
          end

          context 'when given an invalid or nonexistant group id' do
            it 'renders not found' do
              xhr :get, :index, format: :json, organization_id: raceteam.slug, group_id: 'foobar'
              expect(response.status).to eq 404
              expect(response.body).to be_blank
            end
          end

        end
        context 'of an organization that the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: sfhealth.slug
            expect(response.status).to eq 404
            expect(response.body).to be_blank
          end
        end
        context 'of an organization that does not exist current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: 'foobar'
            expect(response.status).to eq 404
            expect(response.body).to be_blank
          end
        end
      end
    end

    # post /api/:organization_id/conversations
    describe 'create' do
      context 'when given valid conversation data' do
        it 'creates and returns the new conversation' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation: { subject: 'my conversation' }
          expect(response.status).to eq 201
          conversation = raceteam.conversations.find_by_slug('my-conversation')
          expect(conversation).to be
          expect(response.body).to eq Api::ConversationsSerializer[conversation].to_json
        end
      end

      context 'with an organization that the user is not a member of' do
        it 'returns a 404' do
          xhr :post, :create, format: :json, organization_id: sfhealth.slug, conversation: { subject: 'my conversation' }
          expect(response.status).to eq 404
          expect(response.body).to be_blank
        end
      end

      context 'with no subject' do
        it 'raises an ParameterMissing error' do
          expect {
            xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation: {  }
          }.to raise_error(ActionController::ParameterMissing)
        end
      end

      context 'with a blank subject' do
        it 'raises an ParameterMissing error' do
          expect {
            xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation: { subject: '' }
          }.to raise_error(ActionController::ParameterMissing)
        end
      end
    end

    # get /api/:organization_id/:id
    describe 'show' do
      # context 'when given a valid organization id' do
      #   it "should render the current users's organizations as json" do
      #     xhr :get, :show, format: :json, id: raceteam.id
      #     expect(response).to be_ok
      #     expect(response.body).to eq Api::OrganizationsSerializer[raceteam].to_json
      #   end
      # end
      # context 'when given an invalid organization id' do
      #   it "should render the current users's organizations as json" do
      #     xhr :get, :show, format: :json, id: 32843874832
      #     expect(response.status).to eq 404
      #     expect(response.body).to be_blank
      #   end
      # end
    end

    # patch /api/:organization_id/:id
    describe 'update' do

    end

    # delete /api/:organization_id/:id
    describe 'destroy' do

    end

  end


end
