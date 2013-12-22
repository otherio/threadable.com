require_dependency 'covered/organization'

class Covered::Organization::Tasks < Covered::Tasks

  def initialize organization
    @organization = organization
    @covered = organization.covered
  end
  attr_reader :organization

  def find_by_slug! slug
    find_by_slug(slug) or raise Covered::RecordNotFound, "unable to find Task with slug #{slug.inspect}"
  end

  def build attributes={}
    conversation_for scope.build(attributes)
  end
  alias_method :new, :build

  def create attributes={}
    super attributes.merge(organization: organization)
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization.id.inspect}>)
  end

  private

  def scope
    organization.organization_record.tasks
  end

end
