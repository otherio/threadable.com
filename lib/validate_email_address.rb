class ValidateEmailAddress < MethodObject

  def call email_address_string
    mail_address = Mail::Address.new(email_address_string)
    # We must check that value contains a domain and that value is an email address
    return false unless mail_address.domain
    return false unless mail_address.address == email_address_string
    return true if Rails.env.development? && email_address_string =~ /localhost/
    tree = mail_address.__send__(:tree)
    # We need to dig into treetop
    # A valid domain must have dot_atom_text elements size > 1
    # user@localhost is excluded
    # treetop must respond to domain
    # We exclude valid email values like <user@localhost.com>
    # Hence we use mail_address.__send__(tree).domain
    return false unless (tree.domain.dot_atom_text.elements.size > 1)
    return true
  rescue Mail::Field::ParseError
    return false
  end

end
