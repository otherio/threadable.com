class Covered::Project

  include Let
  extend ActiveSupport::Autoload

  autoload :Members
  autoload :Member
  autoload :Conversations
  autoload :Conversation
  autoload :Tasks
  autoload :Task

  def self.model_name
    ::Project.model_name
  end

  def initialize covered, project_record
    @covered, @project_record = covered, project_record
  end
  attr_reader :covered, :project_record

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
    "#{project_record.email_address_username}@#{covered.email_host}"
  end

  def formatted_email_address
    "#{name} <#{email_address}>"
  end

  def list_id
    "#{project_record.email_address_username}.#{covered.email_host}"
  end

  def formatted_list_id
    "#{name} <#{list_id}>"
  end

  let(:members){ Members.new(self) }
  let(:conversations){ Conversations.new(self) }
  let(:tasks){ Tasks.new(self) }

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

  def inspect
    %(#<#{self.class} project_id: #{id.inspect}, name: #{name.inspect}>)
  end

  def == other
    self.class === other && other.id == id
  end
end
