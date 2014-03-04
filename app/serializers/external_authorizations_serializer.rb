class ExternalAuthorizationsSerializer < Serializer

  self.singular_record_name = :external_authorization
  self.plural_record_name = :external_authorizations

  def serialize_record external_authorization
    {
      provider:        external_authorization.provider,
      name:            external_authorization.name,
      email_address:   external_authorization.email_address,
      nickname:        external_authorization.nickname,
      url:             external_authorization.url,
      token:           external_authorization.token,
      application_key: external_authorization.application_key,
    }
  end

end
