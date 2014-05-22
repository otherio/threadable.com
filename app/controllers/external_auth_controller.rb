class ExternalAuthController < ApplicationController

  def create
    provider = params.require(:provider)

    raise Threadable::RecordNotFound unless provider == 'trello' || provider == 'google_oauth2'
    return render nothing: true, status: :bad_request unless auth_hash && auth_hash.has_key?('credentials')

    # some fucking case/switch thing to make a google one
    # trello only for now
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
        name: auth_hash['info']['name'],
        email_address: auth_hash['info']['email'],
      }
    end

    current_user.external_authorizations.add_or_update!(params)
    redirect_to('/')
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
