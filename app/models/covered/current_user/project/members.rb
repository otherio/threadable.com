class Covered::CurrentUser::Project::Members < Covered::Project::Members

  def me
    find_by_user_id! project.current_user.id
  end


  def add user, personal_message=nil
    super
  end

  def remove member
    super
  end

  private

  def member_for project_membership_record
    Covered::CurrentUser::Project::Member.new(project, project_membership_record)
  end

end
