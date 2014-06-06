require_dependency 'threadable/group/member'

class Threadable::Group::Members < Threadable::Collection

  def initialize group
    @group = group
    @threadable = group.threadable
  end
  attr_reader :group

  def all
    members_for scope
  end

  def all_with_email_addresses
    members_for scope.includes(user: :email_addresses)
  end

  def find_by_user_id user_id
    member_for (scope.where(user_id:user_id).first or return)
  end

  def find_by_user_id! user_id
    find_by_user_id(user_id) or
      raise Threadable::RecordNotFound, "unable to find group member with id: #{user_id}"
  end

  def current_member
    @current_member = nil if @current_member && @current_member.user_id != threadable.current_user_id
    raise Threadable::AuthorizationError if threadable.current_user_id.nil?
    @current_member ||= find_by_user_id! threadable.current_user_id
  end

  def add user, options={}
    group_membership_record = group.group_record.memberships.find_or_initialize_by(user_id: user.user_id)
    if group_membership_record.new_record?
      group_membership_record.save!
      if options[:send_notice] != false && threadable.current_user.present? && threadable.current_user.id != user.id
        threadable.emails.send_email_async(:added_to_group_notice, group.organization.id, group.id, threadable.current_user.id, user.id)
      end
    end
    GoogleSyncWorker.perform_async(threadable.env, group.organization.id, group.id) if group.google_sync?

    member_for group_membership_record
  end

  def remove user, options={}
    group.group_record.memberships
    group.group_record.members.delete(user.user_record)

    if options[:send_notice] != false && threadable.current_user.present? && threadable.current_user.id != user.id
      threadable.emails.send_email_async(:removed_from_group_notice, group.organization.id, group.id, threadable.current_user.id, user.id)
    end
    GoogleSyncWorker.perform_async(threadable.env, group.organization.id, group.id) if group.google_sync?

    self
  end

  def include? member
    return false unless member.respond_to?(:user_id)
    !!group.group_record.memberships.where(user_id: member.user_id).exists?
  end

  def inspect
    %(#<#{self.class} organization_id: #{group.organization.id.inspect} group_id: #{group.id.inspect}>)
  end

  private

  def scope
    group.group_record.memberships.unload
  end

  def member_for group_membership_record
    Threadable::Group::Member.new(group, group_membership_record)
  end

  def members_for group_membership_records
    group_membership_records.map do |group_membership_record|
      member_for group_membership_record
    end
  end

end
