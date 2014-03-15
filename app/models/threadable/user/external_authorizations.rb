require_dependency 'threadable/user'
require_dependency 'threadable/user/external_authorization'

class Threadable::User::ExternalAuthorizations < Threadable::ExternalAuthorizations

  def initialize user
    @user    = user
    @threadable = user.threadable
  end
  attr_reader :user

  def inspect
    %(#<#{self.class} user_id: #{user.id}>)
  end

  private

  def scope
    user.user_record.external_authorizations.unload
  end

  def external_authorization_for external_authorization_record
    Threadable::User::ExternalAuthorization.new(user, external_authorization_record) if external_authorization_record
  end
end
