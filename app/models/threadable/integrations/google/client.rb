require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

module Threadable::Integrations::Google::Client
  def client_for user
    unless external_authorization = user.external_authorizations.find_by_provider('google_oauth2')
      raise(Threadable::ExternalServiceError, 'No connected google account')
    end

    @google_api_client ||= ::Google::APIClient.new(
      application_name: 'Threadable',
      application_version: '1.0'
    )

    @google_api_client.authorization.access_token = external_authorization.token
    @google_api_client.authorization.refresh_token = external_authorization.refresh_token
    @google_api_client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
    @google_api_client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
    @google_api_client
  end

  def directory_api
    raise(Threadable::ExternalServiceError, 'No client present') unless @google_api_client
    @google_directory_api ||= @google_api_client.discovered_api('admin', 'directory_v1')
  end

  def groups_settings_api
    raise(Threadable::ExternalServiceError, 'No client present') unless @google_api_client
    @google_groups_settings_api ||= @google_api_client.discovered_api('groupssettings')
  end

  def extract_error_message response
    begin
      JSON.parse(response.body)['error']['message']
    rescue JSON::ParserError, TypeError
      nil
    end || '(no error message found)'
  end

end
