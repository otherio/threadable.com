require 'spec_helper'

describe OrganizationsController, :type => :controller do

  let(:creator){ double(:creator) }
  let(:new_organization){ double(:new_organization, creator: creator) }

  let(:mixpanel_distinct_id){ SecureRandom.uuid }

  before do
    request.cookies[TrackingConcern::MixpanelCookie::MIXPANEL_COOKIE_NAME] = {
      distinct_id: mixpanel_distinct_id
    }.to_json
  end

  when_not_signed_in do

    describe "GET new" do
      it "redirects to the sign in page" do
        get :new, {}
        expect(response).to redirect_to sign_in_path(r: new_organization_path)
        expect(trackings).to be_blank
      end

      context 'when part of the sign up flow' do
        let(:organization_name){ 'my new org' }
        let(:email_address){ 'michael.faraday@gmail.com' }
        let(:token){ SignUpConfirmationToken.encrypt(organization_name, email_address) }

        it "renders the new organization form" do
          expect(NewOrganization).to receive(:new).with(controller, organization_name: organization_name, your_email_address: email_address).and_return(new_organization)
          expect(new_organization).to receive(:organization_name  ).and_return(organization_name)
          expect(new_organization).to receive(:your_email_address ).and_return(email_address)

          get :new, {token: token}
          expect(response).to render_template :new
          assert_tracked(mixpanel_distinct_id, 'New Organization Page Visited',
            sign_up_confirmation_token: true,
            organization_name: organization_name,
            email_address: email_address,
          )
        end
      end
    end

    describe "POST create" do
      it "redirects to the sign in page" do
        post :create, {}
        expect(response).to redirect_to sign_in_path(r: new_organization_path)
        expect(trackings).to be_blank
      end

      context 'when part of the sign up flow' do
        let(:organization_name){ 'my new org' }
        let(:email_address){ 'michael.faraday@gmail.com' }
        let(:token){ SignUpConfirmationToken.encrypt(organization_name, email_address) }

        context 'when the new organization is not valid' do
          before{ expect(new_organization).to receive(:create).and_return(false) }
          it "assigns a NewOrganization instance to @new_organization and renders new" do
            expect(NewOrganization).to receive(:new).with(controller, 'organization_name' => organization_name, 'your_email_address' => email_address).and_return(new_organization)
            expect(controller).to_not receive(:sign_in!)
            expect(controller).to_not receive(:redirect_to)
            post :create, {
              token: token,
              new_organization: {organization_name: organization_name}
            }
            expect(response).to be_success
            expect(assigns(:new_organization)).to be new_organization
            expect(response).to render_template :new
            expect(trackings).to be_blank
          end
        end

        context 'when the new organization is valid' do
          let(:new_organization_params) do
            {
              organization_name:      organization_name,
              email_address_username: 'my-new-org',
              your_name:              'michael Faraday',
              password:               'passest of words',
              password_confirmation:  'passest of words',
            }
          end

          let(:email_address) { 'Michael.Faraday@gmail.com' }

          it "assigns a NewOrganization instance to @new_organization, creates the organization and signs in as the creator" do
            post :create, {
              token: token,
              new_organization: new_organization_params
            }

            new_organization = threadable.organizations.find_by_slug('my-new-org')
            expect(new_organization.name).to eq 'my new org'
            expect(response).to redirect_to controller.conversations_url('my-new-org', 'my')

            new_user = threadable.users.find_by_email_address(email_address)
            assert_tracked(new_user.id, 'Organization Created',
              sign_up_confirmation_token: true,
              organization_name: organization_name,
              email_address: email_address,
              organization_id: 345,
            )
          end
        end
      end

    end
  end

  when_signed_in_as 'bethany@ucsd.example.com' do
    describe "GET new" do
      it "assigns a NewOrganization instance to @new_organization" do
        expect(NewOrganization).to receive(:new).with(controller, organization_name: nil, your_email_address: nil).and_return(new_organization)
        expect(new_organization).to receive(:organization_name ).and_return(nil)
        expect(new_organization).to receive(:your_email_address).and_return(nil)
        get :new, {}
        expect(assigns(:new_organization)).to be new_organization
        expect(response).to render_template :new
        assert_tracked(threadable.current_user.user_id, 'New Organization Page Visited',
          sign_up_confirmation_token: false,
          organization_name: nil,
          email_address: nil,
        )
      end
    end

    describe "POST create" do
      context 'when the new organization is not valid' do
        before{ expect(new_organization).to receive(:create).and_return(false) }
        it "assigns a NewOrganization instance to @new_organization and renders new" do
          expect(NewOrganization).to receive(:new).with(controller, {'organization_name' => 'my new org', 'your_email_address' => nil}).and_return(new_organization)
          expect(new_organization).to_not receive(:your_email_address=)
          expect(controller).to_not receive(:sign_in!)
          expect(controller).to_not receive(:redirect_to)
          post :create, {
            new_organization: {organization_name: 'my new org'}
          }
          expect(response).to be_success
          expect(assigns(:new_organization)).to be new_organization
          expect(response).to render_template :new
          expect(trackings).to be_blank
        end
      end
      context 'when the new organization is valid' do
        before{ expect(new_organization).to receive(:create).and_return(true) }
        it "assigns a NewOrganization instance to @new_organization and creates the organization" do
          expect(NewOrganization).to receive(:new).with(controller, {'organization_name' => 'my new org', 'your_email_address' => nil}).and_return(new_organization)
          organization = double(:organization, to_param: 'my-new-org', id: 8844)
          expect(new_organization).to receive(:organization_name ).and_return('my new org')
          expect(new_organization).to receive(:your_email_address).and_return(nil)
          expect(new_organization).to receive(:organization).twice.and_return(organization)
          expect(controller).to_not receive(:sign_in!)
          post :create, {
            new_organization: {organization_name: 'my new org'}
          }
          expect(assigns(:new_organization)).to be new_organization
          expect(response).to redirect_to controller.conversations_url('my-new-org', 'my')
          assert_tracked(threadable.current_user.user_id, 'Organization Created',
            sign_up_confirmation_token: false,
            organization_name: 'my new org',
            email_address: nil,
            organization_id: 8844,
          )
        end
      end
    end
  end

end
