require_dependency 'threadable/organization/members'

class Threadable::Organization::Members::Remove < MethodObject

  def call members, options
    @members      = members
    @threadable   = members.threadable
    @organization = members.organization
    @scope        = @members.send(:scope)
    @options      = options

    delete_organization_membership!
    track!
    return
  end

  def user_id
    @user_id ||= @options[:user_id] || @options[:user].try(:user_id) or
      raise ArgumentError, "unable to determine user id from #{@options.inspect}"
  end

  def delete_organization_membership!
    original_member_count = @organization.members.count

    Threadable.transaction do
      @scope.where(user_id: user_id).delete_all
      billforward = Threadable::Billforward.new(organization: @organization)
      billforward.update_member_count original_member_count
    end
  end

  def track!
    @threadable.track("Removed User", {
      'Removed User' => user_id.to_i,
      'Organization'      => @organization.id,
      'Organization Name' => @organization.name,
    })
  end

end
