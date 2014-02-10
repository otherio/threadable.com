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
  }, to: :user_record

  delegate *%w{
    gets_email?
    subscribed?
  }, to: :organization_membership_record

  def to_param
    id
  end

  def organization_membership_id
    organization_membership_record.id
  end

  def user
    @user ||= Threadable::User.new(threadable, user_record)
  end

  def reload
    organization_membership_record.reload
    self
  end

  def subscribe! track=false
    return if subscribed?
    if track
      threadable.track('Re-subscribed', {
        'Organization'      => organization.id,
        'Organization Name' => organization.name,
      })
    end
    organization_membership_record.subscribe!
  end

  def unsubscribe! track=false
    return if !subscribed?
    if track
      threadable.track('Unsubscribed', {
        'Organization'      => organization.id,
        'Organization Name' => organization.name,
      })
    end
    organization_membership_record.unsubscribe!
  end

  def == other
    self.class === other && self.user_id == other.user_id && self.organization_id == other.organization_id
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization_id.inspect}, user_id: #{user_id.inspect}>)
  end

end
