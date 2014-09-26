require_dependency 'threadable/organization'
require_dependency 'threadable/organization/group'

class Threadable::Organization::Groups < Threadable::Groups

  def initialize organization, options = {}
    @organization = organization
    @threadable = organization.threadable
    @options = options
  end
  attr_reader :organization, :options

  def find_by_ids group_ids
    groups_for scope.where(id: group_ids)
  end

  def find_by_ids! group_ids
    groups = find_by_ids group_ids
    groups.length == group_ids.length or raise Threadable::RecordNotFound, 'Unable to find one of the specified groups'
    groups
  end

  def find_by_id group_id
    find_by_ids([group_id]).try(:first)
  end

  def find_by_id! id
    find_by_id(id) or raise Threadable::RecordNotFound, "unable to find group with id #{id.inspect}"
  end

  def find_by_email_address_tag email_address_tag
    group_for (scope.where(email_address_tag: email_address_tag.downcase).first or return)
  end
  alias_method :find_by_slug, :find_by_email_address_tag

  def find_by_email_address_tag! email_address_tag
    find_by_email_address_tag(email_address_tag) or raise Threadable::RecordNotFound, "unable to find group with email address tag #{email_address_tag.inspect}"
  end

  def find_by_slug! slug
    find_by_slug(slug) or raise Threadable::RecordNotFound, "unable to find group with slug #{slug.inspect}"
  end

  def find_by_email_address_tags email_address_tags
    email_address_tags = email_address_tags.map(&:downcase)
    group_records = scope.where('email_address_tag in (?)', email_address_tags).to_a
    email_address_tags.map do |email_address_tag|
      group_for group_records.find{|group| group.email_address_tag == email_address_tag}
    end
  end

  def find_by_email_address_tags! email_address_tags
    groups = find_by_email_address_tags(email_address_tags)
    raise Threadable::RecordNotFound if groups.reject{|g| g.nil?} != groups
    groups
  end

  def all_for_user user
    if threadable.current_user && ! organization.members.current_member.can?(:read_private, self)
      groups_for scope.where(group_memberships: {user_id: user.id})
    else
      groups_for scope.joins(:members).where(group_memberships: {user_id: user.id})
    end
  end

  def auto_joinable
    groups_for scope.where(auto_join: true)
  end

  def create attributes={}
    Create.call(self, attributes);
  end

  def create! attributes={}
    group = create(attributes)
    group.persisted? or raise Threadable::RecordInvalid, "Group invalid: #{group.errors.full_messages.to_sentence}"
    group
  end

  def primary
    @primary_group ||= group_for scope.where(primary: true).first
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization.id.inspect}>)
  end

  private

  def scope
    if options[:unrestricted]
      return organization.organization_record.groups
    end

    if threadable.current_user && organization.members.current_member
      if organization.members.current_member.can?(:read_private, self)
        organization.organization_record.groups
      else
        organization.organization_record.groups.
          joins('LEFT JOIN group_memberships scope_group_memberships on groups.id = scope_group_memberships.group_id').
          where("groups.private = 'f' OR scope_group_memberships.user_id = #{threadable.current_user_id}").
          group('groups.id')
      end
    else
      if threadable.worker?
        organization.organization_record.groups
      else
        organization.organization_record.groups.where(private: false)
      end
    end
  end

  def group_for group_record
    Threadable::Organization::Group.new(organization, group_record) if group_record
  end

  def groups_for group_records
    group_records.map{|group_record| group_for group_record }
  end
end

require 'threadable/organization/groups/create'
