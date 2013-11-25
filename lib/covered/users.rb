class Covered::Users

  def initialize covered
    @covered = covered
  end
  attr_reader :covered

  def find_by_email_address email_address
    user_for (::User.find_by_email_address(email_address) or return)
  end

  def find_by_email_address! email_address
    find_by_email_address(email_address) or raise Covered::RecordNotFound, "unable to find user with email address: #{email_address}"
  end

  def find_by_slug slug
    user_for (::User.where(slug:slug).first or return)
  end

  def find_by_slug! slug
    find_by_slug(slug) or raise Covered::RecordNotFound, "unable to find user with slug: #{slug}"
  end

  def find_by_id id
    user_for (::User.where(id:id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Covered::RecordNotFound, "unable to find user with id: #{id}"
  end

  def exists? id
    User.exists?(id) ? id : false
  end

  def exists! id
    exists?(id) or raise Covered::RecordNotFound, "unable to find user with id: #{id}"
  end

  def new attributes={}
    user_for ::User.new(attributes)
  end
  alias_method :build, :new

  def create attributes={}
    user_for Create.call(covered, attributes)
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

  def user_for user_record
    Covered::User.new(covered, user_record)
  end

  # def find_by_email_address email_address
  #   user = User.find_by_email_address(email_address) or raise Covered::RecordNotFound
  #   Covered::CurrentUser.new(user)

  # end


  # def create options
  #   scope.create(options)
  # end

  # def find options
  #   scope.where(options)
  # end

  # def get options
  #   find(slug: options.fetch(:slug)).first or raise Covered::RecordNotFound
  # end

  # def new
  #   scope.new
  # end

  # private

  # def scope
  #   User
  # end

end

require 'covered/user'