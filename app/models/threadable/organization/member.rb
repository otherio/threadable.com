require_dependency 'threadable/organization'

class Threadable::Organization::Member < Threadable::User

  def initialize organization, organization_membership_record
    @organization, @organization_membership_record = organization, organization_membership_record
    organization.id == organization_membership_record.organization_id or raise ArgumentError
    @threadable = organization.threadable
  end
  attr_reader :organization, :organization_membership_record
  delegate :organization_id, :user_id, to: :organization_membership_record
  delegate :organization_record, to: :organization

  def user_record
    organization_membership_record.user
  end

  delegate *%w{
    id
    name
    avatar_url
    to_param
  }, to: :user_record

  delegate *%w{
    gets_email?
    subscribed?
    role
    confirmed?
  }, to: :organization_membership_record

  OrganizationMembership::ROLES.each do |role|
    define_method("#{role}?"){ self.role == role }
  end

  let(:groups) { Threadable::Organization::Member::Groups.new(self) }

  def organization_membership_id
    organization_membership_record.id
  end

  def summarized_conversations time
    conversations = []

    groups.with_summary.each do |group|
      conversations += group.conversations.for_message_summary(self, time)
    end

    conversations
  end

  def user
    @user ||= Threadable::User.new(threadable, user_record)
  end

  def reload
    organization_membership_record.reload
    self
  end

  def update organization_membership_attributes
    user_attributes = organization_membership_attributes.slice!(*Threadable::Organization::Member::Update::ATTRIBUTES)
    if organization_membership_attributes.present?
      Threadable::Organization::Member::Update.call(self, organization_membership_attributes)
    end
    if user_attributes.present?
      user.update(user_attributes)
    end
    return self
  end

  def remove
    current_member = organization.members.current_member

    if !current_member.can?(:delete, @organization.members)
      raise Threadable::AuthorizationError, 'You cannot remove members from this organization'
    end

    original_member_count = organization.members.count

    Threadable.transaction do
      organization.groups.all_for_user(user).each do |group|
        group.members.remove user, send_notice: false
      end

      organization.tasks.all_for_user(user).each do |task|
        task.doers.remove [user]
      end

      organization_membership_record.update_attribute(:active, false)
    end

    @threadable.track("Removed User", {
      'User'                  => id,
      'Organization'          => @organization.id,
      'Organization Name'     => @organization.name,
    })
  end

  def subscribe!
    update subscribed: true
  end

  def unsubscribe!
    update subscribed: false
  end

  def confirm!
    return if confirmed?
    @threadable.emails.send_email_async(:confirmation_notice, @organization.id, id)
    organization_membership_record.update_attribute(:confirmed, true)
  end

  def unconfirm!
    organization_membership_record.update_attribute(:confirmed, false)
  end

  def == other
    self.class === other && self.user_id == other.user_id && self.organization_id == other.organization_id
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization_id.inspect}, user_id: #{user_id.inspect}>)
  end

end

require_dependency 'threadable/organization/member/update'
