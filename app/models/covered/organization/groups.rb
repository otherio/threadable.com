require_dependency 'covered/organization'
require_dependency 'covered/organization/group'

class Covered::Organization::Groups < Covered::Groups

  def initialize organization
    @organization = organization
    @covered = organization.covered
  end
  attr_reader :organization

  def find_by_email_address_tag email_address_tag
    group_for (scope.where(email_address_tag: email_address_tag).first or return)
  end

  def find_by_email_address_tag! email_address_tag
    find_by_email_address_tag(email_address_tag) or raise Covered::RecordNotFound, "unable to find group with email address tag #{email_address_tag.inspect}"
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
    super attributes.merge({organization: @organization.organization_record})
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

end
