class Covered::Project::Members

  def initialize project
    @project = project
  end
  attr_reader :project
  delegate :covered, to: :project

  def all
    scope.reload.map{|membership| member_for membership }
  end

  def that_get_email
    scope.that_get_email.reload.map{|membership| member_for membership }
  end

  def find_by_user_id id
    member_for (scope.where(users:{id:id}).first or return)
  end

  def find_by_user_id! id
    member = find_by_user_id(id)
    member or raise Covered::RecordNotFound, "unable to find project member with id: #{id}"
    member
  end

  def find_by_user_slug slug
    member_for (scope.where(users:{slug:slug}).first or return)
  end

  def find_by_user_slug! slug
    member = find_by_user_slug(slug)
    member or raise Covered::RecordNotFound, "unable to find project member with slug: #{slug}"
    member
  end

  def find_by_email_address email_address
    member_for (
      scope.includes(:email_addresses)
        .where(email_addresses:{address:email_address})
        .references(:email_addresses)
        .first or return
    )
  end

  def find_by_email_address! email_address
    member = find_by_user_email_address(email_address)
    member or raise Covered::RecordNotFound, "unable to find project member with email_address: #{email_address}"
    member
  end

  def me
    find_by_user_id covered.current_user_id if covered.current_user_id
  end

  def include? member
    !!scope.where(:user_id => member.user_id).exists?
  end

  def new
    member_for scope.new(user: ::User.new)
  end

  # add(user: user, send_join_notice: false)
  # add(user: user, personal_message: "welcome!")
  # add(name: 'Steve Waz', email_address: "steve@waz.io", personal_message: "welcome!")
  def add options
    send_join_notice = options.fetch(:send_join_notice){ true }

    user_id = case
    when options.key?(:user_id)
      covered.users.exists! options[:user_id]
    when options.key?(:email_address)
      (
        covered.users.find_by_email_address(options[:email_address]) or
        covered.users.create!(name: options[:name], email_address: options[:email_address])
      ).id
    when options[:user].respond_to?(:user_id)
      options[:user].user_id
    else
      raise ArgumentError, "unable to determine user id from #{options.inspect}"
    end

    unless member = scope.where(user_id: user_id).first
      member = scope.create!(user_id: user_id, gets_email: options[:gets_email] != false)

      if send_join_notice
        covered.emails.send_email_async(:join_notice, project.id, user_id, options[:personal_message])
      end
    end

    covered.track("Added User", {
      'Invitee' => user_id,
      'Project' => project.id,
      'Project Name' => project.name,
      'Sent Join Notice' => send_join_notice ? true : false,
      'Sent Personal Message' => options[:personal_message].present?
    })

    member_for member
  end

  # remove(user: member)
  # remove(user: user)
  # remove(user_id: user_id)
  def remove options
    if options.key?(:user) && options[:user].respond_to?(:project_membership_id)
      scope.delete options[:user].project_membership_id
      return self
    end

    user_id = options[:user_id] || options[:user].try(:user_id) or
      raise ArgumentError, "unable to determine user id from #{options.inspect}"

    covered.track("Removed User", {
      'Removed User' => user_id,
      'Project' => project.id,
      'Project Name' => project.name,
    })

    scope.where(user_id: user_id).delete_all
    self
  end


  def as_json options=nil
    all.as_json(options)
  end

  def inspect
    %(#<#{self.class} project_id: #{project.id.inspect}>)
  end

  private

  def scope
    project.project_record.memberships.includes(:user).reload
  end

  def member_for project_membership_record
    Covered::Project::Member.new(project, project_membership_record)
  end

end
