class Covered::User::Organization::Groups < Covered::Organization::Groups

  def initialize organization
    super
    @user = organization.user
  end
  attr_reader :user


end
