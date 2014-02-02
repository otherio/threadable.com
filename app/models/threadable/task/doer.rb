require_dependency 'threadable/task'

class Threadable::Task::Doer < Threadable::Model

  def initialize task, user_record
    @task, @user_record = task, user_record
    @threadable = task.threadable
  end
  attr_reader :task, :user_record

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
    @user ||= Threadable::User.new(threadable, user_record)
  end

  def member
    @member ||= task.organization.members.find_by_user_id!(user_id)
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
