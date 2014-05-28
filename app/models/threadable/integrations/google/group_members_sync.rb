class Threadable::Integrations::Google::GroupMembersSync < MethodObject

  include Threadable::Integrations::Google::Client


  def call threadable, group
    google_client = client_for(threadable.current_user)

    list_response = google_client.execute(
      api_method: directory_api.members.list,
      parameters: {'groupKey' => group.email_address, 'maxResults' => 1000},
    )

    raise Threadable::ExternalServiceError, 'Could not retrieve google group users' unless list_response.status == 200

    emails = JSON.parse(list_response.body)['members'].map{ |google_member| google_member['email'] }
    missing_members = group.members.all_with_email_addresses.select do |member|
      ! (member.email_addresses.all.map(&:address) & emails).present?
    end

    missing_members.each do |member|
      insert_response = google_client.execute(
        api_method: directory_api.members.insert,
        parameters: {'groupKey' => group.email_address},
        body_object: {
          'email' => member.email_address.address
        }
      )

      raise Threadable::ExternalServiceError, 'Adding user to google group failed' unless insert_response.status == 200
    end
  end

end
