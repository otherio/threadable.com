require_dependency 'threadable/user'
require_dependency 'threadable/user/organization'

class Threadable::User::Organizations < Threadable::Organizations

  def initialize user
    @user = user
  end

  attr_reader :user
  delegate :threadable, to: :user

  def inspect
    %(#<#{self.class} for_user: #{user.inspect}>)
  end

  def unconfirmed
    scope.where(organization_memberships: { confirmed: false }).map{ |organization| organization_for organization }
  end

  private

  def scope
    user.user_record.organizations
  end

  def organization_for organization_record
    Threadable::User::Organization.new(self, organization_record)
  end

end
