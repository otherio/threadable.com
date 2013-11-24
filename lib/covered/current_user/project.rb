class Covered::CurrentUser::Project

  def self.model_name
    ::Project.model_name
  end

  def initialize current_user, project_record
    @current_user, @project_record = current_user, project_record
  end
  attr_reader :current_user, :project_record
  delegate :covered, to: :current_user

  delegate *%w{
    id
    to_param
    name
    short_name
    slug
    subject_tag
    description
    errors
    new_record?
    persisted?
  }, to: :project_record

  def to_key
    id ? [id] : nil
  end

  def email_address
    "#{project_record.email_address_username}@#{covered.host}"
  end

  def formatted_email_address
    "#{name} <#{email_address}>"
  end

  def list_id
    "#{project_record.email_address_username}.#{covered.host}"
  end

  def formatted_list_id
    "#{name} <#{list_id}>"
  end

  def members
    @members ||= Members.new(self)
  end

  def conversations
    @conversations ||= Conversations.new(self)
  end

  def messages
    @messages ||= Messages.new(self)
  end

  # def messages
  #   @messages ||= Messages.new(self)
  # end

  def tasks
    @tasks ||= Tasks.new(self)
  end

  def as_json options=nil
    {
      id:          id,
      param:       to_param,
      name:        name,
      short_name:  short_name,
      slug:        slug,
      subject_tag: subject_tag,
      description: description,
    }
  end


  def update attributes
    project_record.update_attributes(attributes)
  end

  def leave!
    project_record.memberships.where(user_id: current_user.id).first.try(:delete)
  end


  def inspect
    %(#<#{self.class} project_id: #{id.inspect}, name: #{name.inspect}>)
  end

  def == other
    self.class === other && other.id == id
  end
end

require 'covered/current_user/project/members'
require 'covered/current_user/project/conversations'
require 'covered/current_user/project/messages'
require 'covered/current_user/project/tasks'
require 'covered/current_user/project/messages'
