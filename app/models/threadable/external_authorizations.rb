require_dependency 'threadable/user'
require_dependency 'threadable/user/external_authorization'

class Threadable::ExternalAuthorizations < Threadable::Collection

  def initialize threadable
    @threadable = threadable
  end
  attr_reader :threadable

  def all
    external_authorizations_for scope
  end

  def find_by_unique_id id
    external_authorization_for scope.where(unique_id: id).first
  end

  def for_provider provider
    external_authorization_for scope.where(provider: provider).first
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
    %(#<#{self.class}>)
  end

  private

  def scope
    ::ExternalAuthorization
  end

  def external_authorization_for external_authorization_record
    user = Threadable::User.new(threadable, external_authorization_record.user)
    Threadable::User::ExternalAuthorization.new(user, external_authorization_record) if external_authorization_record
  end

  def external_authorizations_for external_authorization_records
    external_authorization_records.map{ |external_authorization_record| external_authorization_for external_authorization_record }
  end


end
