require_dependency 'covered/project/members'

class Covered::Project::Members::Remove < MethodObject

  def call members, options
    @members = members
    @covered = members.covered
    @project = members.project
    @scope   = @members.send(:scope)
    @options = options

    delete_project_membership!
    track!
    return
  end

  def user_id
    @user_id ||= @options[:user_id] || @options[:user].try(:user_id) or
      raise ArgumentError, "unable to determine user id from #{@options.inspect}"
  end

  def delete_project_membership!
    @scope.where(user_id: user_id).delete_all
  end

  def track!
    @covered.track("Removed User", {
      'Removed User' => user_id,
      'Project'      => @project.id,
      'Project Name' => @project.name,
    })
  end

end
