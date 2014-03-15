class ExternalAuthController < ApplicationController

  def create
    provider = params.require(:provider)

    raise Threadable::RecordNotFound if provider != 'trello'
    return render nothing: true, status: :bad_request unless auth_hash && auth_hash.has_key?('credentials')

    # trello only for now
    params = {
      provider: provider,
      token: auth_hash['credentials']['token'],
      secret: auth_hash['credentials']['secret'],
      name: auth_hash['info']['name'],
      email_address: auth_hash['info']['email'],
      nickname: auth_hash['info']['nickname'],
      url: auth_hash['info']['urls']['profile'],
      unique_id: auth_hash['uid'],
    }

    current_user.external_authorizations.add_or_update!(params)
    redirect_to('/')
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
