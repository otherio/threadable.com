require 'spec_helper'

describe ExternalAuthController do

  describe "POST create" do
    let(:auth_hash) do
      {
        'provider' => 'trello',
        'credentials' => {
          'token' => 'TOKEN',
          'secret' => 'SECRET',
        },
      }
    end

    before do
      request.env['omniauth.auth'] = auth_hash
    end

    when_signed_in_as 'yan@ucsd.example.com' do
      context "with a valid oauth callback" do
        it "should render succesfully" do
          post :create, provider: 'trello'
          expect(response).to be_success
          expect(response.body).to be_blank
          expect(current_user.external_authorizations.all.length).to eq 1
        end
      end

      context "with an incorrect provider" do
        it "should render not found" do
          post :create, provider: 'faxtagram'
          expect(response.status).to eq 404
        end
      end

      context "with no secret or token" do
        let(:auth_hash) {}
        it "should render bad request" do
          post :create, provider: 'trello'
          expect(response.status).to eq 400
        end
      end
    end
  end

end
