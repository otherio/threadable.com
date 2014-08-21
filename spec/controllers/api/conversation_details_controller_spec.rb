require 'spec_helper'

describe Api::ConversationDetailsController, :type => :controller do

  when_not_signed_in do
    describe 'show' do
      it 'renders unauthorized' do
        xhr :get, :show, format: :json, organization_id: 1, id: 1
        expect(response.status).to eq 401
      end
    end
  end

  when_signed_in_as 'bob@ucsd.example.com' do

    let(:raceteam){ threadable.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ threadable.organizations.find_by_slug! 'sfhealth' }
    let(:conversations) { }

    describe 'show' do
      let(:conversation) { raceteam.conversations.find_by_slug('layup-body-carbon')}

      context 'when given a valid conversation id' do
        it "renders the conversation details as json" do
          xhr :get, :show, format: :json, id: conversation.slug, organization_id: raceteam.slug
          expect(response).to be_ok
          expect(response.body).to eq serialize(:conversation_details, conversation).to_json
        end
      end

      context 'when given an invalid conversation id' do
        it "throws an error" do
          xhr :get, :show, format: :json, id: 32843874832, organization_id: raceteam.slug
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find Conversation with slug \"32843874832\""}'
        end
      end
    end
  end
end
