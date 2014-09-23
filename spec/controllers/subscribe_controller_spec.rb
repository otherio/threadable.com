require 'spec_helper'

describe SubscribeController, type: :controller, fixtures: true do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }

  include EmberRouteUrlHelpers

  before do
    WebMock.disable_net_connect!
  end

  when_not_signed_in do
    describe '#show' do
      it 'redirects to sign_in' do
        get :show, organization_id: organization.slug
        expect(response.status).to eq 302
      end
    end

    describe '#wait' do
      it 'redirects to sign_in' do
        get :wait, organization_id: organization.slug
        expect(response.status).to eq 302
      end
    end

    describe '#callback' do
      let(:params) do
        {
          "type" => "notification",
          "domain" => "Subscription",
          "entityID" => "the_subscription_id",
        }
      end

      let(:response_data) do
        {
          'results' => [
            {
              'id' => 'the_subscription_id',
              'accountID' => 'the_account_id',
              'state' => 'Paid',
            }
          ]
        }
      end

      let(:token) { ENV['THREADABLE_BILLFORWARD_TOKEN'] }

      before do
        ENV['THREADABLE_BILLFORWARD_API_URL'] = 'https://sandbox.billforward.net'
        organization.organization_record.update_attributes(billforward_account_id: 'the_account_id', billforward_subscription_id: 'the_subscription_id', plan: :free)
        stub_request(:get, "https://sandbox.billforward.net/subscriptions/the_subscription_id?access_token=#{token}").to_return(
          body: response_data.to_json,
          headers: {'Content-type' => 'application/json'},
          status: 200,
        )
      end

      it 'fetches the subscription and sets the org to paid' do
        post :callback, params
        expect(response.status).to eq 200
        organization.reload
        expect(organization.paid?).to be_truthy
      end
    end

  end

  when_signed_in_as 'alice@ucsd.example.com' do
    describe '#show' do
      let(:billforward) { double(:billforward)}
      before do
        expect(Threadable::Billforward).to receive(:new).and_return(billforward)
        organization.update(billforward_subscription_id: 'subscription_id', billforward_account_id: 'account_id')
      end

      it 'creates a subscription and redirects to billforward' do
        expect(billforward).to receive(:update_member_count)
        get :show, organization_id: organization.slug
        url = ENV['THREADABLE_BILLFORWARD_CHECKOUT_URL']
        expect(response).to redirect_to "#{url}/subscription/subscription_id?wanted_state=AwaitingPayment&redirect=#{subscribe_wait_url(organization)}&force_redirect=true"
      end
    end

    describe '#wait' do
      context 'when the organization is paid' do
        before do
          organization.update(plan: :paid)
        end

        it 'redirects to the organization settings' do
          get :wait, organization_id: organization.slug
          expect(response).to redirect_to organization_settings_path(organization)
        end
      end

      context 'when the org is unpaid' do
        before do
          organization.update(plan: :free)
        end

        it 'displays the waiting page when retries < 2' do
          get :wait, organization_id: organization.slug, retries: 2
          expect(response).to render_template :waiting
        end

        it 'sets the org as paid anyway, mails an error, and redirects when retries > 2' do
          get :wait, organization_id: organization.slug, retries: 3
          expect(response).to redirect_to organization_settings_path(organization)
          organization.reload
          expect(organization.paid?).to be_truthy
          drain_background_jobs!
          expect(sent_emails.with_subject("Billing Callback Error")).to be
        end
      end
    end
  end
end
