class Covered::CurrentUser::Project::Members

  def initialize project
    @project = project
  end
  attr_reader :project
  delegate :covered, to: :project

  def all
    scope.map{|membership| member_for membership }
  end

  def that_get_email
    scope.that_get_email.map{|membership| member_for membership }
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

  def me
    find_by_user_id! project.current_user.id
  end

  def add user, personal_message=nil
    user_id = if user.is_a? Hash
      if user[:email_address]
        (covered.users.find_by_email_address(user[:email_address]) or covered.users.create!(user)).id
      else
        covered.users.exists! user[:id]
      end
    else
      user.user_id
    end
    member = member_for scope.create!(user_id: user_id)
    covered.emails.send_email_async(:join_notice, project.id, member.id, personal_message)
    member
  rescue ActiveRecord::RecordNotUnique
    raise Covered::UserAlreadyAMemberOfProjectError
  end

  def remove member
    if member.respond_to?(:project_membership_id)
      scope.delete(project_membership_id)
    else
      user_id = member.respond_to?(:user_id) ? member.user_id : member
      scope.where(user_id: user_id).delete_all
    end
    self
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
    project.project_record.memberships.includes(:user)
  end

  def member_for project_membership_record
    Covered::CurrentUser::Project::Member.new(project, project_membership_record)
  end

end
