require_dependency 'covered/organization'

class Covered::Organization::Members < Covered::Collection

  def initialize organization
    @organization = organization
    @covered = organization.covered
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
    member or raise Covered::RecordNotFound, "unable to find organization member with id: #{id}"
    member
  end

  def find_by_user_slug slug
    member_for (scope.where(users:{slug:slug}).first or return)
  end

  def find_by_user_slug! slug
    member = find_by_user_slug(slug)
    member or raise Covered::RecordNotFound, "unable to find organization member with slug: #{slug}"
    member
  end

  def find_by_email_address email_address
    member_for (
      scope.includes(:email_addresses)
        .where(email_addresses:{address:email_address.strip_non_ascii})
        .references(:email_addresses)
        .first or return
    )
  end

  def find_by_email_address! email_address
    member = find_by_email_address(email_address)
    member or raise Covered::RecordNotFound, "unable to find organization member with email_address: #{email_address}"
    member
  end

  def me
    find_by_user_id covered.current_user_id if covered.current_user_id
  end

  def email_addresses
    EmailAddress.joins(:user => :organizations).where(organizations: {id: organization.id}).each do |email_address_record|
      Covered::EmailAddress.new(covered, email_address_record)
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
    Covered::Organization::Member.new(organization, organization_membership_record)
  end

end
