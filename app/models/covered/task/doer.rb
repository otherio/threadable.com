require_dependency 'covered/task'

class Covered::Task::Doer

  def initialize task, user_record
    @task, @user_record = task, user_record
  end
  attr_reader :task, :user_record
  delegate :covered, to: :task

  delegate *%w{
    id
    to_param
    name
    email_address
    slug
    avatar_url
  }, to: :user_record
  alias_method :user_id, :id

  def user
    @user ||= Covered::User.new(covered, user_record)
  end

  def member
    @member ||= task.project.members.find_by_user_id!(user_id)
  end

  def == other
    self.class === other && self.id == other.id
  end

  def inspect
    %(#<#{self.class} task_id: #{task.id} user_id: #{id}>)
  end

  def as_json options=nil
    {
      id: id,
      params: to_param,
      name: name,
      email_address: email_address,
      avatar_url: avatar_url,
    }
  end

end
