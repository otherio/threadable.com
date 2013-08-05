# Usage:
#
# AddMemberToProject.call(
#   actor: current_user,
#   project: project,
#   member: user
# )
#
# AddMemberToProject.call(
#   actor: current_user,
#   project: project,
#   member: {
#     email: 'steve@example.com',
#     name: 'Steve Sampson'
#   },
#   message: 'Hey Steve, I added you to our project.'
# )
#
#
class AddMemberToProject < MethodObject.new(:options)

  class UserAlreadyAMemberOfProjectError < ArgumentError
    def initialize user, project
      @user, @project = user, project
    end
    attr_reader :user, :project
  end

  def call
    @actor   = @options.fetch(:actor)
    @project = @options.fetch(:project)
    @member  = @options.fetch(:member)
    @message = @options[:message]

    find_or_initialize_member!
    save_member!
    create_project_membership!
    send_join_notice! if @message.present?
    @member
  end

  def find_or_initialize_member!
    case
    when @member.is_a?(User)
      # do nothing
    when @member.key?(:id)
      @member = User.find(@member[:id])
    when @member.key?(:email)
      @member = User.with_email(@member[:email]).first_or_initialize(@member)
    else
      raise ArgumentError, 'member option should be a user or a has with either an :id or :email key'
    end
  end

  def save_member!
    return if @member.persisted?
    @member.skip_confirmation_notification!
    @member.save!
  end

  def create_project_membership!
    if @member.project_memberships.where(:project => @project).exists?
      raise UserAlreadyAMemberOfProjectError.new(@member, @project)
    end
    @project_membership = @member.project_memberships.create(:project => @project)
  end

  def send_join_notice!
    ProjectMembershipMailer.join_notice(@project_membership, @actor, @message).deliver
  end

end
