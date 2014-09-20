require 'spec_helper'
require 'webmock/rspec'

describe Threadable::Billforward, :type => :request do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:token) { ENV['THREADABLE_BILLFORWARD_TOKEN'] }

  let(:billforward) { described_class.new(organization: organization) }
  subject { billforward }

  before do
    ENV['THREADABLE_BILLFORWARD_API_URL'] = 'https://sandbox.billforward.net'
    ENV['THREADABLE_BILLFORWARD_PRO_PLAN_ID'] = 'the_pro_plan_id'
    ENV['THREADABLE_BILLFORWARD_PEOPLE_COMPONENT_ID'] = 'the_people_component_id'
    ENV['THREADABLE_BILLFORWARD_PRO_PRODUCT_ID'] = 'the_pro_product_id'
    sign_in_as 'alice@ucsd.example.com'
  end

  describe 'init' do
    it 'can be initialized with an org directly' do
      expect(billforward.organization).to eq organization
    end

    context 'when initialized with a subscription id' do
      let(:billforward) { described_class.new(subscription_id: organization.billforward_subscription_id, threadable: organization.threadable) }

      before do
        organization.update(billforward_subscription_id: 'the_subscription_id')
      end

      it 'finds the organization' do
        expect(billforward.organization).to eq organization
      end
    end
  end

  describe '#create_account' do
    context 'with valid data' do

      let(:account_data) do
        {
          "profile" => {
            "email" => "alice@ucsd.example.com",
            "firstName" => "Alice",
            "lastName" => "Neilson",
            "addresses" => [],
          },
          "roles" => [
            {
              "role" => "pro"
            }
          ]
        }
      end

      let(:response_data) do
        {
          "results" => [
            {
              "@type" => "account",
              "id" => "the_account_id",
              "profile" => {
                "email" => "alice@ucsd.example.com",
                "firstName" => "Alice",
                "lastName" => "Neilson",
              },
              "roles" => [
                {
                  "role" => "pro"
                }
              ]
            }
          ]
        }
      end

      before do
        stub_request(:post, 'https://sandbox.billforward.net/accounts').with(
          body: account_data.to_json,
          headers: {'Authorization' => "Bearer #{token}", 'Content-type' => 'application/json'},
        ).to_return(
          body: response_data.to_json,
          headers: {'Content-type' => 'application/json'},
          status: 200,
        )
      end

      it 'creates the account for the organization' do
        billforward.create_account
        expect(organization.billforward_account_id).to eq 'the_account_id'
      end
    end

    context 'with an error response' do
      before do
        stub_request(:post, 'https://sandbox.billforward.net/accounts').to_return(
          body: {
            errorType: 'StuffBrokenError',
            errorMessage: 'Things are broken',
            errorParameters: ['one', 'two']
          }.to_json,
          headers: {'Content-type' => 'application/json'},
          status: 500,
        )
      end

      it 'raises an exception' do
        expect { billforward.create_account }.to raise_error Threadable::ExternalServiceError, "Unable to create account: Things are broken"
      end
    end
  end

  describe '#create_subscription' do
    before do
      organization.update(billforward_account_id: 'the_account_id')
    end

    context 'with valid data' do

      let(:subscription_data) do
        {
          'accountID'         => 'the_account_id',
          'productID'         => 'the_pro_product_id',
          'productRatePlanID' => 'the_pro_plan_id',
          'name'              => "Pro: #{organization.name}",
          'type'              => "Subscription",

          'pricingComponentValues' => [
            'pricingComponentID' => 'the_people_component_id',
            'value'              => organization.members.count
          ]
        }
      end

      let(:response_data) do
        {
          "results" => [
            {
              "@type" => "subscription",
              "id" => "the_subscription_id",
            }
          ]
        }
      end

      before do
        stub_request(:post, 'https://sandbox.billforward.net/subscriptions').with(
          body: subscription_data.to_json,
          headers: {'Authorization' => "Bearer #{token}", 'Content-type' => 'application/json'},
        ).to_return(
          body: response_data.to_json,
          headers: {'Content-type' => 'application/json'},
          status: 200,
        )
      end

      it 'creates the subscription for the organization' do
        billforward.create_subscription
        expect(organization.billforward_subscription_id).to eq 'the_subscription_id'
      end
    end

    context 'with an error response' do
      before do
        stub_request(:post, 'https://sandbox.billforward.net/subscriptions').to_return(
          body: {
            errorType: 'StuffBrokenError',
            errorMessage: 'Things are broken',
            errorParameters: ['one', 'two']
          }.to_json,
          headers: {'Content-type' => 'application/json'},
          status: 500,
        )
      end

      it 'raises an exception' do
        expect { billforward.create_subscription }.to raise_error Threadable::ExternalServiceError, "Unable to create subscription: Things are broken"
      end
    end
  end

  describe '#update_member_count' do
    before do
      organization.update(billforward_account_id: 'the_account_id', billforward_subscription_id: 'the_subscription_id')
      Timecop.freeze
    end

    context 'with valid data' do
      let(:component_value_change_data) do
        {
          'id' => 'the_subscription_id',
          'accountID' => 'the_account_id',
          'productID' => 'the_pro_product_id',
          'productRatePlanID' => 'the_pro_plan_id',
          'name' => "Pro: #{organization.name}",
          'type' => "Subscription",

          'pricingComponentValueChanges' => [
            {
              'pricingComponentID' => 'the_people_component_id',
              'value' => organization.members.count,
              'mode' => 'delayed',
              'state' => 'New',
              'asOf' => Time.now.utc.iso8601,
            }
          ]
        }
      end

      let(:response_data) do
        {
          "results" => [
            {
              "@type" => "subscription",
              "id" => "the_subscription_id",
            }
          ]
        }
      end

      before do
        stub_request(:put, 'https://sandbox.billforward.net/subscriptions').with(
          body: component_value_change_data.to_json,
          headers: {'Authorization' => "Bearer #{token}", 'Content-type' => 'application/json'},
        ).to_return(
          body: response_data.to_json,
          headers: {'Content-type' => 'application/json'},
          status: 200,
        )
      end

      it 'sets the member count at billforward' do
        billforward.update_member_count
      end
    end
  end

  describe '#update_paid_status' do
    before do
      sign_out!
    end

    context 'with a successful request' do
      let(:response_data) do
        {
          'id' => 'the_subscription_id',
          'accountID' => 'the_account_id',
          'state' => state,
        }
      end

      before do
        organization.organization_record.update_attributes(billforward_account_id: 'the_account_id', billforward_subscription_id: 'the_subscription_id')

        stub_request(:get, 'https://sandbox.billforward.net/subscriptions/the_subscription_id').with(
          headers: {'Authorization' => "Bearer #{token}"},
        ).to_return(
          body: response_data.to_json,
          headers: {'Content-type' => 'application/json'},
          status: 200,
        )
      end

      context 'when the subscription is Paid' do
        let(:state) { 'Paid' }

        it 'switches the org to paid' do
          organization.free!
          billforward.update_paid_status
          expect(organization.paid?).to be_truthy
        end
      end

      context 'when the subscription is Trial' do
        let(:state) { 'Trial' }

        it 'switches the org to paid' do
          organization.free!
          billforward.update_paid_status
          expect(organization.paid?).to be_truthy
        end
      end

      context 'when the subscription is any other state (Cancelled, Failed, Provisioned, etc)' do
        let(:state) { 'Thingers' }

        it 'switches the org to paid' do
          organization.paid!
          billforward.update_paid_status
          expect(organization.paid?).to be_falsy
        end
      end
    end

    context 'with a failed request' do
      before do
        organization.organization_record.update_attributes(billforward_account_id: 'the_account_id', billforward_subscription_id: 'the_subscription_id')

        stub_request(:get, 'https://sandbox.billforward.net/subscriptions/the_subscription_id').to_return(
          body: {
            errorType: 'StuffBrokenError',
            errorMessage: 'Things are broken',
            errorParameters: ['one', 'two']
          }.to_json,
          headers: {'Content-type' => 'application/json'},
          status: 500,
        )
      end

      it 'raises an exception' do
        expect { billforward.update_paid_status }.to raise_error Threadable::ExternalServiceError, "Unable to fetch subscription for raceteam: Things are broken"
      end
    end
  end

end
