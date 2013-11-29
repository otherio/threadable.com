class Covered::User

  include Let

  extend ActiveSupport::Autoload

  autoload :EmailAddresses
  autoload :EmailAddress
  autoload :Projects
  autoload :Messages

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
    email_address
    slug
    admin?
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

  let(:email_addresses){ EmailAddresses.new(self) }
  let(:projects)       { Projects.new(self)     }
  let(:messages)       { Messages.new(self)     }

  def web_enabled?
    user_record.encrypted_password.present?
  end

  def requires_setup?
    !web_enabled?
  end

  def formatted_email_address
    "#{name} <#{email_address}>"
  end

  def confirm!
    !!update(confirmed_at: Time.now)
  end

  def confirmed?
    user_record.confirmed_at.present?
  end

  def update attributes
    !!user_record.update_attributes(attributes)
  end

  def update! attributes
    update(attributes)
    user_record.errors.empty? or
    raise Covered::RecordInvalid, "User invalid: #{user_record.errors.full_messages.to_sentence}"
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

  def same_user? user
     user.respond_to?(:user_id) && self.user_id == user.user_id
  end
  alias_method :the_same_user_as?, :same_user?

  def == other
    self.class === other && self.user_id == other.user_id
  end

  def inspect
    %(#<#{self.class} user_id: #{id}>)
    # %(#<#{self.class} id: #{id}, email_address: #{email_address.inspect}, slug: #{slug.inspect}>)
  end

end
