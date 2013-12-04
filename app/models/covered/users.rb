class Covered::Users < Covered::Collection

  extend ActiveSupport::Autoload
  autoload :Create

  def initialize covered
    @covered = covered
  end
  attr_reader :covered

  def all
    scope.includes(:email_addresses).map{ |project| user_for project }
  end

  def find_by_email_address email_address
    user_for (scope.find_by_email_address(email_address) or return)
  end

  def find_by_email_address! email_address
    find_by_email_address(email_address) or raise Covered::RecordNotFound, "unable to find user with email address: #{email_address}"
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

end
