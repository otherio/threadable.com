require_dependency 'threadable/user/group_membership'

class Threadable::User::GroupMemberships < Threadable::Collection

  def initialize user
    @user    = user
    @threadable = user.threadable
  end
  attr_reader :user

  def all
    group_memberships_for scope
  end

  def limited
    group_memberships_for scope.where(delivery_method: [::GroupMembership.delivery_methods[:gets_in_summary], ::GroupMembership.delivery_methods[:gets_first_message]] )
  end

  # def for_organization organization
  #   group_memberships_for scope.for_organization(organization.id)
  # end

  private

  def scope
    user.user_record.group_memberships.unload
  end

  def group_membership_for group_membership_record
    Threadable::User::GroupMembership.new(user, group_membership_record) if group_membership_record
  end

  def group_memberships_for group_membership_records
    group_membership_records.map do |group_membership_record|
      group_membership_for group_membership_record
    end
  end

end
