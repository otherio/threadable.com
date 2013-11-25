class Covered::Project::Members

  def initialize project
    @project = project
  end
  attr_reader :project
  delegate :covered, to: :project

  def all
    scope.reload.map{|membership| member_for membership }
  end

  def that_get_email
    scope.that_get_email.reload.map{|membership| member_for membership }
  end

  def find_by_user_id id
    member_for (scope.where(users:{id:id}).first or return)
  end

  def find_by_user_id! id
    member = find_by_user_id(id)
    member or raise Covered::RecordNotFound, "unable to find project member with id: #{id}"
    member
  end

  def find_by_user_slug slug
    member_for (scope.where(users:{slug:slug}).first or return)
  end

  def find_by_user_slug! slug
    member = find_by_user_slug(slug)
    member or raise Covered::RecordNotFound, "unable to find project member with slug: #{slug}"
    member
  end

  def include? member
    !!scope.where(:user_id => member.user_id).exists?
  end

  def as_json options=nil
    all.as_json(options)
  end

  def inspect
    %(#<#{self.class} project_id: #{project.id.inspect}>)
  end

  private

  def scope
    project.project_record.memberships.includes(:user).reload
  end

  def member_for project_membership_record
    Covered::Project::Member.new(project, project_membership_record)
  end

end
