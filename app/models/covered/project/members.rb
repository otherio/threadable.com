class Covered::Project::Members < Covered::Collection

  autoload :Add
  autoload :Remove

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
    member = find_by_email_address(email_address)
    member or raise Covered::RecordNotFound, "unable to find project member with email_address: #{email_address}"
    member
  end

  def me
    find_by_user_id covered.current_user_id if covered.current_user_id
  end

  def email_addresses
    EmailAddress.joins(:user => :projects).where(projects: {id: project.id}).each do |email_address_record|
      Covered::EmailAddress.new(covered, email_address_record)
    end
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
    member_for Add.call(self, options)
  end

  # remove(user: member)
  # remove(user: user)
  # remove(user_id: user_id)
  def remove options
    Remove.call(self, options)
    return self
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
