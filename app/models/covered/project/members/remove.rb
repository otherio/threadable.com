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

  def given_a_member?
    options.key?(:user) && options[:user].respond_to?(:project_membership_id)
  end

  def delete_project_membership!
    if given_a_member?
      @scope.delete options[:user].project_membership_id
    else
      @scopescope.where(user_id: user_id).delete_all
    end
  end

  def user_id
    @user_id ||= options[:user_id] || options[:user].try(:user_id) or
      raise ArgumentError, "unable to determine user id from #{options.inspect}"
  end

  def track!
    @covered.track("Removed User", {
      'Removed User' => user_id,
      'Project'      => @project.id,
      'Project Name' => @project.name,
    })
  end

end
