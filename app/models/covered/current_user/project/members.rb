class Covered::CurrentUser::Project::Members < Covered::Project::Members

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

  private

  def member_for project_membership_record
    Covered::CurrentUser::Project::Member.new(project, project_membership_record)
  end

end
