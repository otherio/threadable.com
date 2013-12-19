class Covered::Users < Covered::Collection

  def initialize covered
    @covered = covered
  end
  attr_reader :covered

  def all
    users_for scope.includes(:email_addresses).to_a
  end

  def find_by_email_address email_address
    user_for (scope.find_by_email_address(email_address.strip_non_ascii) or return)
  end

  def find_by_email_address! email_address
    find_by_email_address(email_address) or raise Covered::RecordNotFound, "unable to find user with email address: #{email_address}"
  end

  def find_by_email_addresses email_addresses
    email_addresses = covered.email_addresses.find_by_addresses(email_addresses)
    user_ids = email_addresses.map{|e| e.try(:user_id) }
    user_records = scope.where(id: user_ids.compact).to_a
    email_addresses.map do |email_address|
      next unless email_address
      user_record = user_records.find do |user_record|
        user_record.user_id == email_address.user_id
      end
      user_record ? user_for(user_record) : nil
    end
  end

  def find_by_slug slug
    user_for (scope.where(slug:slug).first or return)
  end

  def find_by_slug! slug
    find_by_slug(slug) or raise Covered::RecordNotFound, "unable to find user with slug: #{slug}"
  end

  def find_by_id id
    user_for (scope.where(id:id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Covered::RecordNotFound, "unable to find user with id: #{id}"
  end

  def exists? id
    scope.exists?(id) ? id : false
  end

  def exists! id
    exists?(id) or raise Covered::RecordNotFound, "unable to find user with id: #{id}"
  end

  def new attributes={}
    user_for scope.new(attributes)
  end
  alias_method :build, :new

  def create attributes={}
    Create.call(covered, attributes)
  end

  def create! attributes={}
    user = create(attributes)
    user.persisted? or raise Covered::RecordInvalid, "User invalid: #{user.errors.full_messages.to_sentence}"
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
    Covered::User.new(covered, user_record)
  end

  def users_for user_records
    user_records.map{ |user_record| user_for user_record }
  end

end
