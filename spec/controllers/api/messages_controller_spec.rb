require 'spec_helper'

describe Api::MessagesController do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json, organization_id: 1, conversation_id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end
    describe 'create' do
      it 'renders unauthorized' do
        xhr :post, :create, format: :json, organization_id: 1, conversation_id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end
  end

  when_signed_in_as 'bob@ucsd.example.com' do

    let(:raceteam){ covered.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ covered.organizations.find_by_slug! 'sfhealth' }
    let(:conversation){ raceteam.conversations.find_by_slug!('welcome-to-our-covered-organization') }
    let(:messages) { }

    # get /api/messages
    describe 'index' do
      context 'when given an organization id' do
        context 'of an organization that the current user is in' do
          it "renders all the messages of the given conversation as json" do
            xhr :get, :index, format: :json, organization_id: raceteam.slug, conversation_id: conversation.slug
            expect(response).to be_ok
            expect(response.body).to eq Api::MessagesSerializer.serialize(covered, conversation.messages.all).to_json
          end
        end
        context 'of an organization that the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: sfhealth.slug, conversation_id: conversation.slug
            expect(response.status).to eq 404
            expect(response.body).to be_blank
          end
        end
        context 'of a conversation that does not exist or the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: raceteam.slug, conversation_id: 'foobar'
            expect(response.status).to eq 404
            expect(response.body).to be_blank
          end
        end
      end
    end

    # post /api/messages
    describe 'create' do
      context 'when given valid message data' do
        it 'creates and returns the new message' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation_id: conversation.slug, message: { subject: 'my message', body: 'hey', conversation_id: conversation.slug }
          expect(response.status).to eq 201
          message = conversation.messages.latest
          expect(message).to be
          expect(response.body).to eq Api::MessagesSerializer.serialize(covered, message).to_json
        end

        it 'sets sent_via_web to true' do
          expect_any_instance_of(Covered::Conversation::Messages).to receive(:create!).with({subject: 'my message', body: 'hey', sent_via_web: true, creator: current_user})
          xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation_id: conversation.slug, message: { subject: 'my message', body: 'hey', conversation_id: conversation.slug }
        end
      end

      context 'with an organization that the user is not a member of' do
        it 'returns a 404' do
          xhr :post, :create, format: :json, organization_id: sfhealth.slug, conversation_id: conversation.slug, message: { subject: 'my message', body: 'hey', conversation_id: conversation.slug }
          expect(response.status).to eq 404
          expect(response.body).to be_blank
        end
      end

      context 'with a conversation that does not exist' do
        it 'returns a 404' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation_id: 'foobar', message: { subject: 'my message', body: 'hey', conversation_id: conversation.slug }
          expect(response.status).to eq 404
          expect(response.body).to be_blank
        end
      end

      context 'when given invalid message data' do
        it 'returns a 422 unprocessible entity' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, conversation_id: conversation.slug, message: { your: 'mom' }
          expect(response.status).to eq 422
          expect(response.body).to be_blank
        end
      end
    end

    describe 'update' do
    end
  end


end
