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

  def who_are_owners
    scope.who_are_owners.reload.map{|membership| member_for membership }
  end

  def who_get_summaries
    membership_records = scope.who_get_email.who_get_ungrouped_summaries
    grouped_userids = groups_scope.who_get_summaries.map(&:user_id)
    membership_records += scope.who_get_email.where(user_id: grouped_userids)
    membership_records.compact.uniq.map{|membership| member_for membership }
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

  def find_by_email_address! email_address
    member = find_by_email_address(email_address)
    member or raise Threadable::RecordNotFound, "unable to find organization member with email_address: #{email_address}"
    member
  end

  def find_by_name name
    member_for (scope.includes(:user).where('users.name ILIKE ?', name).references(:users).first or return)
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

  def current_member
    raise Threadable::AuthorizationError if threadable.current_user_id.nil?
    @current_member_cache ||= {}
    @current_member_cache[threadable.current_user_id] ||= find_by_user_id(threadable.current_user_id)
  end

  def email_addresses
    EmailAddress.joins(:user => :organizations).where(organizations: {id: organization.id}, organization_memberships: {active: true}).each do |email_address_record|
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
    Add.call(self, options)
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

  def groups_scope
    GroupMembership.for_organization(organization.id).includes(:user).reload
  end

  def scope
    organization.organization_record.memberships.active.includes(:user).reload
  end

  def member_for organization_membership_record
    Threadable::Organization::Member.new(organization, organization_membership_record)
  end

end
