class Threadable::Organizations < Threadable::Collection

  def all
    scope.reload.map{ |organization| organization_for organization }
  end

  def all_by_created_at
    scope.order(:created_at).reload.map{ |organization| organization_for organization }
  end

  def with_subscription
    scope.where('organizations.billforward_subscription_id IS NOT NULL').map{ |organization| organization_for organization }
  end

  def with_last_message_between start_date, end_date
    scope.
      joins(:conversations).
      group('organizations.id').
      having('max(conversations.last_message_at) > ? AND max(conversations.last_message_at) < ?', start_date, end_date).
      map{ |organization| organization_for organization }
  end

  def find_by_slug slug
    organization_for (scope.where(slug: slug).first or return)
  end

  def find_by_slug! slug
    find_by_slug(slug) or raise Threadable::RecordNotFound, "unable to find organization with slug #{slug.inspect}"
  end

  def find_by_id id
    organization_for (scope.where(id: id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Threadable::RecordNotFound, "unable to find organization with id #{id.inspect}"
  end

  def find_by_billforward_subscription_id id
    organization_for (scope.where(billforward_subscription_id: id).first or return)
  end

  def find_by_billforward_subscription_id! id
    find_by_billforward_subscription_id(id) or raise Threadable::RecordNotFound, "unable to find organization with subscription id #{id.inspect}"
  end

  def find_by_email_address email_address
    email_address.present? or return
    email_address_username, host = email_address.downcase.strip_non_ascii.split('@')

    if threadable.email_hosts.include?(host)
      # grab the stuff before the + here.
      if email_address_username =~ /^(.+?)(\+|--)/
        email_address_username = $1
      end
      email_address_username = email_address_username.gsub(/\./, '-')
    else
      domain = threadable.email_domains.find_by_domain(host)
      if domain.present?
        return domain.organization
      end

      email_address_username = host.split('.')[0]
    end

    # return nil if threadable.host != host
    organization_for (scope.where(email_address_username: email_address_username).first or return)
  end

  def find_by_email_address! email_address
    find_by_email_address(email_address) or raise Threadable::RecordNotFound, "unable to find organization with email address #{email_address.inspect}"
  end

  def build attributes={}
    organization_for scope.new(attributes)
  end
  alias_method :new, :build

  def create attributes
    Create.call(self, attributes)
  end

  def create! attributes
    organization = create(attributes)
    organization.persisted? or raise Threadable::RecordInvalid, "Organization invalid: #{organization.errors.full_messages.to_sentence}"
    organization
  end

  private

  def scope
    ::Organization.all
  end

  def organization_for organization_record
    Threadable::Organization.new(threadable, organization_record)
  end

end
