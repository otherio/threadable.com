class Threadable::Users < Threadable::Collection

  def initialize threadable
    @threadable = threadable
  end
  attr_reader :threadable

  def all
    users_for scope.includes(:email_addresses).to_a
  end

  def search *args
    users_for User.search(*args)
  end

  def find_by_email_address email_address
    email_address ||= ''
    user_for (scope.find_by_email_address(email_address.strip_non_ascii) or return)
  end

  def find_by_email_address! email_address
    find_by_email_address(email_address) or raise Threadable::RecordNotFound, "unable to find user with email address: #{email_address}"
  end

  def find_by_email_addresses email_addresses
    email_addresses = threadable.email_addresses.find_by_addresses(email_addresses)
    user_ids = email_addresses.map{|e| e.try(:user_id) }.compact
    user_records = scope.where(id: user_ids).to_a
    email_addresses.map do |email_address|
      next unless email_address
      user_record = user_records.find do |record|
        record.user_id == email_address.user_id
      end
      user_record ? user_for(user_record) : nil
    end
  end

  def find_by_slug slug
    user_for (scope.where(slug:slug).first or return)
  end

  def find_by_slug! slug
    find_by_slug(slug) or raise Threadable::RecordNotFound, "unable to find user with slug: #{slug}"
  end

  def find_by_id id
    user_for (scope.where(id:id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Threadable::RecordNotFound, "unable to find user with id: #{id}"
  end

  def all_email_addresses
    scope.distinct.joins(:organization_memberships).
      where(organization_memberships: {gets_email: true, confirmed: true, active: true}).map do |u|
        address = u.email_addresses.primary.first.address
        first_name, last_name = u.name.split(/\s/, 2)
        next if(address =~ /multifyapp.com/ || address =~ /example.com/)
        [first_name, last_name, address]
      end.compact
  end

  def exists? id
    scope.exists?(id) ? id : false
  end

  def exists! id
    exists?(id) or raise Threadable::RecordNotFound, "unable to find user with id: #{id}"
  end

  def new attributes={}
    user_for scope.new(attributes)
  end
  alias_method :build, :new

  def create attributes={}
    Create.call(threadable, attributes)
  end

  def create! attributes={}
    user = create(attributes)
    user.persisted? or raise Threadable::RecordInvalid, "User invalid: #{user.errors.full_messages.to_sentence}"
    user
  end

  def inspect
    %(#<#{self.class}>)
  end

  private

  def scope
    ::User.all
  end

  def user_for user_record
    Threadable::User.new(threadable, user_record)
  end

  def users_for user_records
    user_records.map{ |user_record| user_for user_record }
  end

end
