class Covered::User < Covered::Model

  self.model_name = ::User.model_name

  def initialize covered, user_record
    raise ArgumentError, 'user record cannot be nil' if user_record.nil?
    @covered, @user_record = covered, user_record
  end
  attr_reader :user_record

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

  let(:email_addresses)  { Covered::User::EmailAddresses  .new(self) }
  let(:organizations)    { Covered::User::Organizations   .new(self) }
  let(:conversations)    { Covered::User::Conversations   .new(self) }
  let(:messages)         { Covered::User::Messages        .new(self) }
  let(:group_memberships){ Covered::User::GroupMemberships.new(self) }

  def group_ids
    group_memberships.all.map(&:group_id)
  end

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
    FormattedEmailAddress.new(display_name: name, address: email_address).to_s
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
    %(#<#{self.class} id: #{id}, email_address: #{email_address.to_s.inspect}, slug: #{slug.inspect}>)
  end

end
