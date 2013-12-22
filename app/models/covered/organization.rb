class Covered::Project < Covered::Model

  def self.model_name
    ::Project.model_name
  end

  def initialize covered, project_record
    @covered, @project_record = covered, project_record
  end
  attr_reader :project_record

  delegate *%w{
    id
    to_param
    name
    short_name
    slug
    email_address_username
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

  def task_email_address
    "#{project_record.email_address_username}+task@#{covered.email_host}"
  end

  def email_addresses
    [email_address, task_email_address]
  end

  def formatted_email_address
    "#{name} <#{email_address}>"
  end

  def formatted_task_email_address
    "#{name} Tasks <#{task_email_address}>"
  end

  def list_id
    "#{project_record.email_address_username}.#{covered.email_host}"
  end

  def formatted_list_id
    "#{name} <#{list_id}>"
  end

  let(:members){ Members.new(self) }
  let(:conversations){ Conversations.new(self) }
  let(:messages){ Messages.new(self) }
  let(:tasks){ Tasks.new(self) }
  let(:incoming_emails){ IncomingEmails.new(self) }
  let(:held_messages){ HeldMessages.new(self) }

  # TODO remove me in favor of a rails json view file
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
    Update.call(self, attributes)
  end

  def destroy!
    project_record.destroy!
  end

  def inspect
    %(#<#{self.class} project_id: #{id.inspect}, name: #{name.inspect}>)
  end

end

