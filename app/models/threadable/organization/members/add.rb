require_dependency 'threadable/organization/members'

class Threadable::Organization::Members::Add < MethodObject

  include Let

  def call members, options
    @members          = members
    @threadable       = members.threadable
    @organization     = members.organization
    @options          = options
    @send_join_notice = @options.fetch(:send_join_notice){ true }
    via_admin        = @options.fetch(:via_admin){ false }

    unless @organization.public_signup? || members.count == 0 || (via_admin && @threadable.current_user.admin?)
      current_member = members.current_member
      current_member.present? or raise Threadable::AuthorizationError, "you must be signed in to add a member to an organization"
      if !current_member.can?(:create, members)
        raise Threadable::AuthorizationError, 'You cannot add members to this organization'
      end
    end

    Threadable.transaction do
      return existing_member if existing_user && existing_member
      create_user! unless existing_user
      create_or_update_membership_record!
      return @new_member
    end
  end

  let :existing_user do
    @user = case
    when @options.key?(:user_id)
      @threadable.users.find_by_id!(@options[:user_id].to_i)
    when @options.key?(:email_address)
      @threadable.users.find_by_email_address(@options[:email_address])
    when @options[:user].respond_to?(:user_id)
      @options[:user]
    end
  end

  let :existing_member do
    membership_record = @organization.organization_record.memberships.where(user_id: @user.id, active: true).first
    membership_record ? Threadable::Organization::Member.new(@organization, membership_record) : nil
  end

  let :former_member do
    membership_record = @organization.organization_record.memberships.where(user_id: @user.id, active: false).first
    membership_record ? Threadable::Organization::Member.new(@organization, membership_record) : nil
  end

  def create_user!
    @options[:email_address].present? or raise ArgumentError, "unable to find or create user from #{@options.inspect}"
    @user = @threadable.users.create!(
      name: @options[:name],
      email_address: @options[:email_address],
      confirm_email_address: true,
    )
  end

  def create_or_update_membership_record!
    @new_member = former_member

    if @new_member
      @new_member.organization_membership_record.update_attribute(:active, true)
    else
      membership_record = @organization.organization_record.memberships.create!(
        user_id:    @user.id,
        gets_email: @options[:gets_email] != false,
        role:       @members.count.zero? ? :owner : :member,
        confirmed:  @options.key?(:confirmed) ? @options[:confirmed] : @organization.trusted?,
      )
      @new_member = Threadable::Organization::Member.new(@organization, membership_record)
    end
    auto_join_groups!
    track!
    send_join_notice! if @send_join_notice
  end

  def track!
    @threadable.track("Added User", {
      'Invitee'               => @user.id,
      'Organization'          => @organization.id,
      'Organization Name'     => @organization.name,
      'Sent Join Notice'      => @send_join_notice ? true : false,
      'Sent Personal Message' => @options[:personal_message].present?
    })
  end

  def send_join_notice!
    case @options[:join_notice]
    when :self_join_notice
      @threadable.emails.send_email_async(:self_join_notice, @organization.id, @user.id)
    when :self_join_notice_confirm
      @threadable.emails.send_email_async(:self_join_notice_confirm, @organization.id, @user.id)
    when nil
      if @new_member.confirmed?
        @threadable.emails.send_email_async(:join_notice, @organization.id, @user.id, @options[:personal_message])
      else
        @threadable.emails.send_email_async(:invitation, @organization.id, @user.id)
      end
    end
  end

  def auto_join_groups!
    @organization.groups.auto_joinable.each do |group|
      group.members.add(@new_member, send_notice: false, auto_join: true)
    end
  end

end
