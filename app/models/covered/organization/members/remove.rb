require_dependency 'covered/organization/members'

class Covered::Organization::Members::Remove < MethodObject

  def call members, options
    @members = members
    @covered = members.covered
    @organization = members.organization
    @scope   = @members.send(:scope)
    @options = options

    delete_organization_membership!
    track!
    return
  end

  def user_id
    @user_id ||= @options[:user_id] || @options[:user].try(:user_id) or
      raise ArgumentError, "unable to determine user id from #{@options.inspect}"
  end

  def delete_organization_membership!
    @scope.where(user_id: user_id).delete_all
  end

  def track!
    @covered.track("Removed User", {
      'Removed User' => user_id.to_i,
      'Organization'      => @organization.id,
      'Organization Name' => @organization.name,
    })
  end

end
