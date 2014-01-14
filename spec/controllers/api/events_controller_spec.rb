require 'spec_helper'

describe Api::EventsController do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json, organization_id: 1, conversation_id: 1
        expect(response.status).to eq 401
      end
    end
  end

  when_signed_in_as 'bob@ucsd.example.com' do

    let(:raceteam){ covered.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ covered.organizations.find_by_slug! 'sfhealth' }
    let(:conversation){ raceteam.conversations.find_by_slug!('welcome-to-our-covered-organization') }
    let(:messages) { }

    # get /api/events
    describe 'index' do
      context 'when given an organization id' do
        context 'of an organization that the current user is in' do
          it "renders all the messages and events of the given conversation as json" do
            xhr :get, :index, format: :json, organization_id: raceteam.slug, conversation_id: conversation.slug
            expect(response).to be_ok
            expect(response.body).to eq Api::EventsSerializer.serialize(covered, conversation.events.with_messages).to_json
          end
        end
        context 'of an organization that the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: sfhealth.slug, conversation_id: conversation.slug
            expect(response.status).to eq 404
          end
        end
        context 'with a conversation that does not exist or the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: raceteam.slug, conversation_id: 'foobar'
            expect(response.status).to eq 404
          end
        end
      end
    end
  end


end
