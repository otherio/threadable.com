module RSpec::Support::Finders

  def find_user_by_slug slug
    User.where(slug: slug).first!
  end

  def find_user_by_email_address email_address
    User.with_email_address(email_address).first!
  end

  def find_project_by_slug slug
    Project.where(slug: slug).first!
  end

end
