require_dependency 'threadable/organization/members'

class Threadable::Organization::Members::Add < MethodObject

  include Let

  def call members, options
    @members          = members
    @threadable       = members.threadable
    @organization     = members.organization
    @options          = options
    @send_join_notice = @options.fetch(:send_join_notice){ true }
    Threadable.transaction do
      return existing_member if existing_user && existing_member
      create_user! unless existing_user
      create_membership_record!
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
    membership_record = @organization.organization_record.memberships.where(user_id: @user.id).first
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

  def create_membership_record!
    membership_record = @organization.organization_record.memberships.create!(
      user_id:    @user.id,
      gets_email: @options[:gets_email] != false,
      role:       @members.count.zero? ? :owner : :member,
    )
    @new_member = Threadable::Organization::Member.new(@organization, membership_record)
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
    @threadable.emails.send_email_async(:join_notice, @organization.id, @user.id, @options[:personal_message])
  end

  def auto_join_groups!
    @organization.groups.auto_joinable.each do |group|
      group.members.add(@new_member, send_notice: false)
    end
  end

end
