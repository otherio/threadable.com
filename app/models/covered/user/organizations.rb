require_dependency 'covered/user'
require_dependency 'covered/user/project'

class Covered::User::Projects < Covered::Projects

  def initialize user
    @user = user
  end

  attr_reader :user
  delegate :covered, to: :user

  def inspect
    %(#<#{self.class} for_user: #{user.inspect}>)
  end

  private

  def scope
    user.user_record.projects
  end

  def project_for project_record
    Covered::User::Project.new(self, project_record)
  end

end
