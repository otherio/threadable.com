class Threadable::User < Threadable::Model

  self.model_name = ::User.model_name

  def initialize threadable, user_record
    raise ArgumentError, 'user record cannot be nil' if user_record.nil?
    @threadable, @user_record = threadable, user_record
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
    current_organization_id
    created_at
    munge_reply_to?
    email_addresses_as_string
    show_mail_buttons?
    secure_mail_buttons?
  }, to: :user_record

  delegate :can?, to: :ability

  alias_method :user_id, :id

  let(:email_addresses)         { Threadable::User::EmailAddresses        .new(self) }
  let(:external_authorizations) { Threadable::User::ExternalAuthorizations.new(self) }
  let(:organizations)           { Threadable::User::Organizations         .new(self) }
  let(:conversations)           { Threadable::User::Conversations         .new(self) }
  let(:tasks)                   { Threadable::User::Tasks                 .new(self) }
  let(:groups)                  { Threadable::User::Groups                .new(self) }
  let(:accessible_groups)       { Threadable::User::AccessibleGroups      .new(self) }
  let(:messages)                { Threadable::User::Messages              .new(self) }
  let(:group_memberships)       { Threadable::User::GroupMemberships      .new(self) }

  def group_ids
    group_memberships.all.map(&:group_id)
  end

  def limited_group_ids
    group_memberships.limited.map(&:group_id)
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

  def authenticate(password)
    !!user_record.authenticate(password)
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
    raise Threadable::RecordInvalid, "User invalid: #{user_record.errors.full_messages.to_sentence}"
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

  def merge_into! destination_user
    MergeInto.call(self, destination_user)
  end

  def track_update!
    threadable.tracker.track_user_change(self)
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

  def receives_email_for_groups? groups
    group_ids = groups.map(&:id)
    user_record.groups.
      where(id: group_ids, group_memberships: {summary: false}).present?
  end

  def == other
    (self.class === other || other.class === self) && self.user_id == other.user_id
  end

  def inspect
    %(#<#{self.class} id: #{id}, email_address: #{email_address.to_s.inspect}, slug: #{slug.inspect}>)
  end

  private

  def ability
    @ability ||= ::Ability.new(self)
  end

end
