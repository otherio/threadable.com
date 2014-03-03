class ExternalAuthController < ApplicationController

  def create
    provider = params.require(:provider)

    raise Threadable::RecordNotFound if provider != 'trello'
    return render nothing: true, status: :bad_request unless auth_hash && auth_hash.has_key?('credentials')

    token = auth_hash['credentials']['token']
    secret = auth_hash['credentials']['secret']

    current_user.external_authorizations.add_or_update!(provider: provider, token: token, secret: secret)
    render nothing: true, status: :ok
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
