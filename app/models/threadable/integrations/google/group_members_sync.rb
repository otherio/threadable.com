class Threadable::Integrations::Google::GroupMembersSync < MethodObject

  include Threadable::Integrations::Google::Client

  attr_reader :group

  def call threadable, group
    @group = group

    google_client = client_for(group.organization.google_user)

    list_response = google_client.execute(
      api_method: directory_api.members.list,
      parameters: {'groupKey' => group.email_address, 'maxResults' => 1000},
    )

    raise Threadable::ExternalServiceError, 'Could not retrieve google group users' unless list_response.status == 200

    group_members = group.members.all_with_email_addresses

    members_response = JSON.parse(list_response.body)['members']

    if members_response.present?
      google_group_email_addresses = members_response.map do |google_member|
        google_member['email']
      end
    else
      google_group_email_addresses = []
    end

    missing_members = group_members.select do |member|
      ! (member.email_addresses.all.map(&:address) & google_group_email_addresses).present?
    end

    group_member_email_addresses = group_members.map do |m|
      m.email_addresses.all.map(&:address)
    end.flatten

    extra_email_addresses = google_group_email_addresses - group_member_email_addresses

    missing_members.each do |member|
      insert_response = google_client.execute(
        api_method: directory_api.members.insert,
        parameters: {'groupKey' => group.email_address},
        body_object: {
          'email' => member.email_addresses.for_domain(google_apps_domain).address
        }
      )

      raise Threadable::ExternalServiceError, 'Adding user to google group failed' unless insert_response.status == 200
    end

    extra_email_addresses.each do |email_address|
      delete_response = google_client.execute(
        api_method: directory_api.members.delete,
        parameters: {
          'groupKey' => group.email_address,
          'memberKey' => email_address
        }
      )

      raise Threadable::ExternalServiceError, 'Removing user from google group failed' unless [200, 204, 404].include?(delete_response.status)
    end
  end

  def google_apps_domain
    @google_apps_domain ||= group.organization.google_user.external_authorizations.find_by_provider('google_oauth2').domain
  end

end
