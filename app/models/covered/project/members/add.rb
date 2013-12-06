class Covered::Project::Members::Add < MethodObject

  def call members, options
    @members = members
    @covered = members.covered
    @project = members.project
    @options = options
    @send_join_notice = @options.fetch(:send_join_notice){ true }
    member or create_membership!
    track!
    return member
  end

  def user_id
    @user_id ||= case
    when @options.key?(:user_id)
      @covered.users.exists! @options[:user_id]
    when @options.key?(:email_address)
      (
        @covered.users.find_by_email_address(@options[:email_address]) or
        @covered.users.create!(name: @options[:name], email_address: @options[:email_address])
      ).id
    when @options[:user].respond_to?(:user_id)
      @options[:user].user_id
    else
      raise ArgumentError, "unable to determine user id from #{@options.inspect}"
    end
  end

  def member
    @member ||= @project.project_record.memberships.where(user_id: user_id).first
  end

  def create_membership!
    @member = @project.project_record.memberships.create!(
      user_id: user_id,
      gets_email: @options[:gets_email] != false
    )

    if @send_join_notice
      @covered.emails.send_email_async(:join_notice, @project.id, user_id, @options[:personal_message])
    end
  end

  def track!
    @covered.track("Added User", {
      'Invitee'               => user_id,
      'Project'               => @project.id,
      'Project Name'          => @project.name,
      'Sent Join Notice'      => @send_join_notice ? true : false,
      'Sent Personal Message' => @options[:personal_message].present?
    })
  end


end
