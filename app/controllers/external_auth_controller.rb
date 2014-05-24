class ExternalAuthController < ApplicationController

  def create
    provider = params.require(:provider)

    return render nothing: true, status: :bad_request unless auth_hash && auth_hash.has_key?('credentials')

    case provider
    when 'trello'
      params = {
        provider: provider,
        token: auth_hash['credentials']['token'],
        secret: auth_hash['credentials']['secret'],
        name: auth_hash['info']['name'],
        email_address: auth_hash['info']['email'],
        nickname: auth_hash['info']['nickname'],
        url: auth_hash['info']['urls']['profile'],
      }
    when 'google_oauth2'
      params = {
        provider: provider,
        token: auth_hash['credentials']['token'],
        refresh_token: auth_hash['credentials']['refresh_token'],
        name: auth_hash['info']['name'],
        email_address: auth_hash['info']['email'],
        domain: auth_hash['extra']['raw_info']['hd'],
      }
    else
      raise Threadable::RecordNotFound
    end

    current_user.external_authorizations.add_or_update!(params)
    redirect_to('/')
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
