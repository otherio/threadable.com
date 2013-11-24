Covered::Operations.define :add_member_to_project do

  option :project, required: true
  option :member,  required: true
  option :message
  attr_reader :project_membership

  class UserAlreadyAMemberOfProjectError < ArgumentError
    def initialize user, project
      @user, @project = user, project
    end
    attr_reader :user, :project
  end

  def call
    find_or_initialize_member!
    save_member!
    create_project_membership!
    send_join_notice! if message.present?
    member
  end

  def find_or_initialize_member!
    case
    when member.is_a?(User)
      # do nothing
    when member.key?(:id)
      @member = User.find(member[:id])
    when member.key?(:email)
      @member = User.with_email(member[:email]).first_or_initialize(member)
    else
      raise ArgumentError, "unexpected :member options #{member.inspect}"
    end
  end

  def save_member!
    member.save!
  end

  def create_project_membership!
    if member.project_memberships.where(:project => project).exists?
      raise UserAlreadyAMemberOfProjectError.new(member, project)
    end
    @project_membership = member.project_memberships.create(:project => project)
  end

  def send_join_notice!
    covered.emails.send_email_async(:join_notice, project.id, member.id, personal_message)
  end

end
