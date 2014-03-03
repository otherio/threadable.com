require_dependency 'threadable/user'
require_dependency 'threadable/user/external_authorization'

class Threadable::User::ExternalAuthorizations < Threadable::Collection

  def initialize user
    @user    = user
    @threadable = user.threadable
  end
  attr_reader :user

  def all
    external_authorizations_for scope
  end

  def add_or_update params
    external_authorization_record = nil
    Threadable.transaction do
      external_authorization_record = scope.where(provider: params[:provider]).first
      if(external_authorization_record)
        external_authorization_record.update_attributes(params)
      else
        external_authorization_record = scope.create(params)
      end
    end
    external_authorization_for external_authorization_record
  end

  def add_or_update! params
    external_authorization = add_or_update(params)
    external_authorization.external_authorization_record.persisted? or raise Threadable::RecordInvalid, "external authorization: #{external_authorization.errors.full_messages.to_sentence}"
    external_authorization
  end

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

  def external_authorizations_for external_authorization_records
    external_authorization_records.map{ |external_authorization_record| external_authorization_for external_authorization_record }
  end


end
