class Covered::User

  include Let

  def self.model_name
    ::User.model_name
  end

  def initialize covered, user_record
    raise ArgumentError, 'user record cannot be nil' if user_record.nil?
    @covered, @user_record = covered, user_record
  end
  attr_reader :covered, :user_record

  delegate *%w{
    id
    to_param
    name
    slug
    admin?
    valid?
    errors
    new_record?
    persisted?
    avatar_url
    authenticate
    created_at
  }, to: :user_record

  alias_method :user_id, :id

  def to_key
    id ? [id] : nil
  end

  let(:email_addresses){ EmailAddresses.new(self) }
  let(:projects)       { Organizations.new(self)     }
  let(:messages)       { Messages.new(self)     }

  def web_enabled?
    user_record.encrypted_password.present?
  end

  def requires_setup?
    !web_enabled?
  end

  def email_address
    @email_address ||= email_addresses.primary
  end

  def formatted_email_address
    "#{name} <#{email_address}>"
  end

  def reload
    @email_address = nil
    user_record.reload
    self
  end

  def update attributes
    Update.call(self, attributes)
  end

  def update! attributes
    update(attributes)
    user_record.errors.empty? or
    raise Covered::RecordInvalid, "User invalid: #{user_record.errors.full_messages.to_sentence}"
  end

  def change_password attributes
    current_password      = attributes.fetch(:current_password)
    password              = attributes.fetch(:password)
    password_confirmation = attributes.fetch(:password_confirmation)
    if authenticate(current_password)
      user_record.password = password
      user_record.password_confirmation = password_confirmation
      user_record.save
    else
      user_record.errors.add(:current_password, 'wrong password')
    end
  end

  def track_update!
    covered.tracker.track_user_change(self)
  end

  def as_json options=nil
    {
      id:            id,
      param:         to_param,
      name:          name,
      email_address: email_address.to_s,
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
    # %(#<#{self.class} user_id: #{id}>)
    %(#<#{self.class} id: #{id}, email_address: #{email_address.to_s.inspect}, slug: #{slug.inspect}>)
  end

end
