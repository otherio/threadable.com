module RSpec::Support::Finders

  def find_email_address email_address
    EmailAddress.where(address: email_address).first!
  end

  def find_user_by_slug slug
    User.where(slug: slug).first!
  end

  def find_user_by_email_address email_address
    User.with_email_address(email_address).first!
  end

  def find_organization_by_slug slug
    Organization.where(slug: slug).first!
  end

  def find_conversation_by_slug slug
    Conversation.where(slug: slug).first!
  end

end
