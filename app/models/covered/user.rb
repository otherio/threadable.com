class Covered::User

  def self.model_name
    ::User.model_name
  end

  def initialize covered, user_record
    @covered, @user_record = covered, user_record
  end
  attr_reader :covered, :user_record


  delegate *%w{
    id
    to_param
    name
    slug
    errors
    new_record?
    persisted?
    avatar_url
    authenticate
  }, to: :user_record

  alias_method :user_id, :id

  def to_key
    id ? [id] : nil
  end

  def web_enabled?
    user_record.encrypted_password.present?
  end

  def email_address
    user_record.email_address
  end

  def formatted_email_address
    "#{name} <#{email_address}>"
  end

  def as_json options=nil
    {
      id:            id,
      param:         to_param,
      name:          name,
      email_address: email_address,
      slug:          slug,
      avatar_url:    avatar_url,
    }
  end

  def == other
    self.class === other && self.id == other.id
  end

  def inspect
    %(#<#{self.class} id: #{id}>)
    # %(#<#{self.class} id: #{id}, email_address: #{email_address.inspect}, slug: #{slug.inspect}>)
  end

end
