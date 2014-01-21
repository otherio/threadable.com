require_dependency 'covered/organization'
require_dependency 'covered/organization/group'

class Covered::Organization::Groups < Covered::Groups

  def initialize organization
    @organization = organization
    @covered = organization.covered
  end
  attr_reader :organization

  def find_by_ids group_ids
    groups_for scope.find(group_ids)
  end

  def find_by_email_address_tag email_address_tag
    group_for (scope.where(email_address_tag: email_address_tag).first or return)
  end
  alias_method :find_by_slug, :find_by_email_address_tag

  def find_by_email_address_tag! email_address_tag
    find_by_email_address_tag(email_address_tag) or raise Covered::RecordNotFound, "unable to find group with email address tag #{email_address_tag.inspect}"
  end

  def find_by_slug! slug
    find_by_slug(slug) or raise Covered::RecordNotFound, "unable to find group with slug #{slug.inspect}"
  end

  def find_by_email_address_tags email_address_tags
    group_records = scope.where('email_address_tag in (?)', email_address_tags).to_a
    email_address_tags.map do |email_address_tag|
      group_for group_records.find{|group| group.email_address_tag == email_address_tag}
    end
  end

  def find_by_email_address_tags! email_address_tags
    groups = find_by_email_address_tags(email_address_tags)
    raise Covered::RecordNotFound if groups.reject{|g| g.nil?} != groups
    groups
  end

  def create attributes={}
    Create.call(self, attributes);
  end

  def create! attributes={}
    group = create(attributes)
    group.persisted? or raise Covered::RecordInvalid, "Group invalid: #{group.errors.full_messages.to_sentence}"
    group
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization.id.inspect}>)
  end

  private

  def scope
    organization.organization_record.groups
  end

  def group_for group_record
    Covered::Organization::Group.new(organization, group_record) if group_record
  end

  def groups_for group_records
    group_records.map{|group_record| group_for group_record }
  end

end

require 'covered/organization/groups/create'
