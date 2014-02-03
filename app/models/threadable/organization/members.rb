require_dependency 'threadable/organization'

class Threadable::Organization::Members < Threadable::Collection

  def initialize organization
    @organization = organization
    @threadable = organization.threadable
  end
  attr_reader :organization

  def all
    scope.reload.map{|membership| member_for membership }
  end

  def who_get_email
    scope.who_get_email.reload.map{|membership| member_for membership }
  end

  def find_by_user_id id
    member_for (scope.where(users:{id:id}).first or return)
  end

  def find_by_user_id! id
    member = find_by_user_id(id)
    member or raise Threadable::RecordNotFound, "unable to find organization member with id: #{id}"
    member
  end

  def find_by_user_slug slug
    member_for (scope.where(users:{slug:slug}).first or return)
  end

  def find_by_user_slug! slug
    member = find_by_user_slug(slug)
    member or raise Threadable::RecordNotFound, "unable to find organization member with slug: #{slug}"
    member
  end

  def find_by_email_address email_address
    member_for (
      scope.includes(:email_addresses)
        .where(email_addresses:{address:email_address.downcase.strip_non_ascii})
        .references(:email_addresses)
        .first or return
    )
  end

  def find_by_name name
    member_for (scope.includes(:user).where('users.name ILIKE ?', name).references(:users).first or return)
  end

  def find_by_email_address! email_address
    member = find_by_email_address(email_address)
    member or raise Threadable::RecordNotFound, "unable to find organization member with email_address: #{email_address}"
    member
  end

  def fuzzy_find query
    return nil if query.nil?
    query.gsub!(/\s+/,' ')
    query.strip!
    return nil if query.blank?
    member = @threadable.current_user if query.downcase == 'me'
    member ||= find_by_email_address(query)
    member ||= find_by_name(query)
    member
  end

  def me
    find_by_user_id threadable.current_user_id if threadable.current_user_id
  end

  def email_addresses
    EmailAddress.joins(:user => :organizations).where(organizations: {id: organization.id}).each do |email_address_record|
      Threadable::EmailAddress.new(threadable, email_address_record)
    end
  end

  def include? member
    return false unless member.respond_to?(:user_id)
    !!scope.where(:user_id => member.user_id).exists?
  end

  def new
    member_for scope.new(user: ::User.new)
  end

  # add(user: user, send_join_notice: false)
  # add(user: user, personal_message: "welcome!")
  # add(name: 'Steve Waz', email_address: "steve@waz.io", personal_message: "welcome!")
  def add options
    member_for Add.call(self, options)
  end

  # remove(user: member)
  # remove(user: user)
  # remove(user_id: user_id)
  def remove options
    Remove.call(self, options)
    return self
  end


  def as_json options=nil
    all.as_json(options)
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization.id.inspect}>)
  end

  private

  def scope
    organization.organization_record.memberships.includes(:user).reload
  end

  def member_for organization_membership_record
    Threadable::Organization::Member.new(organization, organization_membership_record)
  end

end
