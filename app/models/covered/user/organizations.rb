require_dependency 'covered/user'
require_dependency 'covered/user/organization'

class Covered::User::Organizations < Covered::Organizations

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
    user.user_record.organizations
  end

  def organization_for organization_record
    Covered::User::Organization.new(self, organization_record)
  end

end
