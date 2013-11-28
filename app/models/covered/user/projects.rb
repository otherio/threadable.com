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

end
