require_dependency 'covered/organization/members'

class Covered::Organization::Members::Add < MethodObject

  def call members, options
    Covered.transaction do
      @members = members
      @covered = members.covered
      @organization = members.organization
      @options = options
      @send_join_notice = @options.fetch(:send_join_notice){ true }
      member or create_membership!
    end
    return member
  end

  def user_id
    @user_id ||= case
    when @options.key?(:user_id)
      @covered.users.exists! @options[:user_id].to_i
    when @options.key?(:email_address)
      find_or_create_user.id
    when @options[:user].respond_to?(:user_id)
      @options[:user].user_id
    else
      raise ArgumentError, "unable to determine user id from #{@options.inspect}"
    end
  end

  def member
    @member ||= @organization.organization_record.memberships.where(user_id: user_id).first
  end

  def create_membership!
    @member = @organization.organization_record.memberships.create!(
      user_id: user_id,
      gets_email: @options[:gets_email] != false
    )
    auto_join_groups!
    track!
    sent_join_notice! if @send_join_notice
  end

  def track!
    @covered.track("Added User", {
      'Invitee'               => user_id,
      'Organization'               => @organization.id,
      'Organization Name'          => @organization.name,
      'Sent Join Notice'      => @send_join_notice ? true : false,
      'Sent Personal Message' => @options[:personal_message].present?
    })
  end

  def sent_join_notice!
    @covered.emails.send_email_async(:join_notice, @organization.id, user_id, @options[:personal_message])
  end

  def auto_join_groups!
    @organization.groups.auto_joinable.each do |group|
      group.members.add(Covered::User.new(@covered, member.user))
    end
  end

  def find_or_create_user
    @covered.users.find_by_email_address(@options[:email_address]) or
    @covered.users.create!(
      name: @options[:name],
      email_address: @options[:email_address],
      confirm_email_address: true,
    )
  end

end
