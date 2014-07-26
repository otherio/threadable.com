require_dependency 'threadable/organization'

class Threadable::Organization::Tasks < Threadable::Tasks

  def initialize organization
    @organization = organization
    @threadable = organization.threadable
  end
  attr_reader :organization

  let(:my)    { Threadable::Organization::Tasks::My   .new(organization) }
  let(:trash) { Threadable::Organization::Tasks::Trash.new(organization) }

  def doing
    return [] if threadable.current_user_id.nil?
    conversations_for scope.untrashed.doing_by(threadable.current_user_id)
  end

  def not_doing
    return [] if threadable.current_user_id.nil?
    conversations_for scope.untrashed.not_doing_by(threadable.current_user_id)
  end


  def find_by_slug! slug
    find_by_slug(slug) or raise Threadable::RecordNotFound, "unable to find Task with slug #{slug.inspect}"
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
    organization.organization_record.tasks.unload
  end

end

require_dependency 'threadable/organization/tasks/my'
