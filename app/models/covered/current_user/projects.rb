class Covered::CurrentUser::Projects < Covered::Projects

  extend ActiveSupport::Autoload

  autoload :Create

  def initialize current_user
    @current_user = current_user
  end

  attr_reader :current_user
  delegate :covered, to: :current_user

  def create attributes
    Create.call(current_user, attributes)
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
