class Threadable::User::Organization::Groups < Threadable::Organization::Groups

  def initialize organization
    super
    @user = organization.user
  end
  attr_reader :user

end
