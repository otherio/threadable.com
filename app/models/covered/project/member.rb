class Covered::Project::Member < Covered::User

  def initialize project, project_membership_record
    @project, @project_membership_record = project, project_membership_record
    project.id == project_membership_record.project_id or raise ArgumentError
  end
  attr_reader :project, :project_membership_record
  delegate :covered, to: :project
  delegate :project_id, :user_id, to: :project_membership_record

  def user_record
    project_membership_record.user
  end

  def project_record
    project_membership_record.project
  end

  delegate *%w{
    id
    name
    avatar_url
  }, to: :user_record

  delegate *%w{
    subscribed?
    subscribe!
    unsubscribe!
  }, to: :project_membership_record

  def to_param
    id
  end

  def project_membership_id
    project_membership_record.id
  end

  def user
    @user ||= Covered::User.new(covered, user_record)
  end

  def reload
    project_membership_record.reload
    self
  end

  def == other
    self.class === other &&
    other.project_membership_record == project_membership_record
  end

  def inspect
    %(#<#{self.class} project_id: #{project_id.inspect}, user_id: #{user_id.inspect}>)
  end

end
