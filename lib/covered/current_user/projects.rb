class Covered::CurrentUser::Projects

  def initialize current_user
    @current_user = current_user
  end

  attr_reader :current_user
  delegate :covered, to: :current_user

  def all
    scope.map{ |project| project_for project }
  end

  def find_by_name name
    project_for (scope.where(name: name).first or return)
  end

  def find_by_name! name
    find_by_name(name) or raise Covered::RecordNotFound, "unable to find project with name #{slug.inspect}"
  end

  def find_by_slug slug
    project_for (scope.where(slug: slug).first or return)
  end

  def find_by_slug! slug
    find_by_slug(slug) or raise Covered::RecordNotFound, "unable to find project with slug #{slug.inspect}"
  end

  def find_by_id id
    project_for (scope.where(id: id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Covered::RecordNotFound, "unable to find project with id #{id.inspect}"
  end

  def find_by_email_address email_address
    email_address_username, host = email_address.split('@')
    return nil if covered.host != host
    project_for (scope.where(email_address_username: email_address_username).first or return)
  end

  def find_by_email_address! email_address
    find_by_email_address(email_address) or raise Covered::RecordNotFound, "unable to find project with email address #{email_address.inspect}"
  end

  def build attributes={}
    project_for scope.new(attributes)
  end
  alias_method :new, :build

  def create attributes
    project_for scope.create(attributes)
  end

  def create! attributes
    project = create(attributes)
    project.persisted? or raise Covered::RecordInvalid, "Project invalid: #{project.errors.full_messages.to_sentence}"
    project
  end

  def inspect
    %(#<#{self.class} current_user_id: #{current_user.id}>)
  end

  private

  def scope
    current_user.user_record.projects
  end

  def project_for project_record
    Covered::CurrentUser::Project.new(current_user, project_record)
  end

end

require 'covered/current_user/projects/create'
