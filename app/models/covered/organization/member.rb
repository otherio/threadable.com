require_dependency 'covered/project'

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
    gets_email?
    subscribed?
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

  def subscribe! track=false
    if track
      covered.track('Re-subscribed', {
        'Project'      => project.id,
        'Project Name' => project.name,
      })
    end

    project_membership_record.subscribe!
  end

  def unsubscribe!
    covered.track('Unsubscribed', {
      'Project'      => project.id,
      'Project Name' => project.name,
    })

    project_membership_record.unsubscribe!
  end

  def == other
    self.class === other && self.user_id == other.user_id && self.project_id == other.project_id
  end

  def inspect
    %(#<#{self.class} project_id: #{project_id.inspect}, user_id: #{user_id.inspect}>)
  end

end
