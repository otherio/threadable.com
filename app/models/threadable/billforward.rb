class Threadable::Billforward
  include HTTParty

  headers 'Authorization' => "Bearer #{ENV['THREADABLE_BILLFORWARD_TOKEN']}"
  headers 'Content-type' => 'application/json'

  def initialize params
    @threadable = params[:threadable] if params[:threadable]

    if params[:organization]
      @organization = params[:organization]
    else
      @organization = threadable.organizations.find_by_billforward_subscription_id!(params[:subscription_id])
    end

    @threadable ||= organization.threadable
    @url          = ENV['THREADABLE_BILLFORWARD_API_URL']
    @token        = ENV['THREADABLE_BILLFORWARD_TOKEN']
  end

  attr_reader :url, :organization, :threadable, :token

  def create_account
    (first_name, last_name) = threadable.current_user.name.split(' ', 2)

    payload = {
      "profile" => {
        "email"     => threadable.current_user.email_address.address,
        "firstName" => first_name,
        "lastName"  => last_name,
        "addresses" => [],
      },
      "roles" => [
        {
          "role" => "pro"
        }
      ]
    }

    response = self.class.post("#{url}/accounts", body: payload.to_json)
    response.code < 300 && response.respond_to?(:[]) or raise Threadable::ExternalServiceError, "Unable to create account: #{response['errorMessage']}"
    organization.update(billforward_account_id: response['results'][0]['id'])
  end

  def create_subscription
    create_account unless organization.billforward_account_id

    member_count = organization.members.who_get_email.count

    payload = {
      'accountID'         => organization.billforward_account_id,
      'productID'         => ENV['THREADABLE_BILLFORWARD_PRO_PRODUCT_ID'],
      'productRatePlanID' => ENV['THREADABLE_BILLFORWARD_PRO_PLAN_ID'],
      'name'              => "Pro: #{organization.name}",
      'type'              => "Subscription",

      'pricingComponentValues' => [
        'pricingComponentID' => ENV['THREADABLE_BILLFORWARD_PEOPLE_COMPONENT_ID'],
        'value'              => member_count,
      ]
    }

    response = self.class.post("#{url}/subscriptions", body: payload.to_json)
    response.code < 300 && response.respond_to?(:[]) or raise Threadable::ExternalServiceError, "Unable to create subscription: #{response['errorMessage']}"
    organization.update(billforward_subscription_id: response['results'][0]['id'], daily_active_users: member_count)
  end

  def update_member_count
    return unless organization.billforward_subscription_id

    old_value = organization.daily_active_users
    new_value = organization.members.who_get_email.count

    return if old_value == new_value

    payload = get_subscription
    payload['pricingComponentValueChanges'] = [
      {
        'pricingComponentID' => ENV['THREADABLE_BILLFORWARD_PEOPLE_COMPONENT_ID'],
        'oldValue' => old_value,
        'newValue' => new_value,
        'mode' => 'delayed',
        'state' => 'New',
        'asOf' => Time.now.utc.iso8601,
      }
    ]

    response = self.class.put("#{url}/subscriptions", body: payload.to_json)
    response.code < 300 && response.respond_to?(:[]) or raise Threadable::ExternalServiceError, "Unable to update active member count: #{response['errorMessage']}"
    organization.organization_record.update_attributes(daily_active_users: new_value)
  end

  def update_paid_status
    return unless organization.billforward_subscription_id

    state = get_subscription['state']
    if state == 'Paid' || state == 'Trial'
      organization.paid!
    else
      organization.free!
    end
  end

  private

  def get_subscription
    response = HTTParty.get("#{url}/subscriptions/#{organization.billforward_subscription_id}?access_token=#{token}")
    response.code < 300 && response.respond_to?(:[]) or raise Threadable::ExternalServiceError, "Unable to fetch subscription for #{organization.slug}: #{response['errorMessage']}"
    response['results'][0]
  end

end
