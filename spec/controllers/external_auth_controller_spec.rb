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
        "info"=> {
          "name"=>"NAME",
          "email"=>"email@foo.com",
          "nickname"=>"NICKNAME",
          "urls"=>{"profile"=>"https://trello.com/foop"}
        },
      }
    end

    before do
      request.env['omniauth.auth'] = auth_hash
    end

    when_signed_in_as 'yan@ucsd.example.com' do
      context "with a valid oauth callback" do
        context "with the trello provider" do
          it "should render succesfully" do
            post :create, provider: 'trello'
            expect(response).to redirect_to('/')
            expect(current_user.external_authorizations.all.length).to eq 1

            auth = current_user.external_authorizations.all.first
            expect(auth.token).to eq 'TOKEN'
            expect(auth.secret).to eq 'SECRET'
            expect(auth.name).to eq 'NAME'
            expect(auth.email_address).to eq 'email@foo.com'
            expect(auth.nickname).to eq 'NICKNAME'
            expect(auth.url).to eq 'https://trello.com/foop'
          end
        end

        context "with the google_oauth2 provider" do
          let(:auth_hash) do
            {
              'provider' => 'google_oauth2',
              'credentials' => {
                'token' => 'TOKEN',
              },
              "info"=> {
                "name"=>"NAME",
                "email"=>"email@foo.com",
              },
            }
          end

          it "should render succesfully" do
            post :create, provider: 'google_oauth2'
            expect(response).to redirect_to('/')
            expect(current_user.external_authorizations.all.length).to eq 1

            auth = current_user.external_authorizations.all.first
            expect(auth.token).to eq 'TOKEN'
            expect(auth.name).to eq 'NAME'
            expect(auth.email_address).to eq 'email@foo.com'
          end
        end
      end

      context "with an incorrect provider" do
        it "should render not found" do
          post :create, provider: 'faxtagram'
          expect(response.status).to eq 404
        end
      end

      context "with no token" do
        let(:auth_hash) {}
        it "should render bad request" do
          post :create, provider: 'trello'
          expect(response.status).to eq 400
        end
      end
    end
  end

end
