require_dependency 'covered/organization'

class Covered::Organization::Member < Covered::User

  def initialize organization, organization_membership_record
    @organization, @organization_membership_record = organization, organization_membership_record
    organization.id == organization_membership_record.organization_id or raise ArgumentError
  end
  attr_reader :organization, :organization_membership_record
  delegate :covered, to: :organization
  delegate :organization_id, :user_id, to: :organization_membership_record

  def user_record
    organization_membership_record.user
  end

  def organization_record
    organization_membership_record.organization
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
    @user ||= Covered::User.new(covered, user_record)
  end

  def reload
    organization_membership_record.reload
    self
  end

  def subscribe! track=false
    if track
      covered.track('Re-subscribed', {
        'Organization'      => organization.id,
        'Organization Name' => organization.name,
      })
    end

    organization_membership_record.subscribe!
  end

  def unsubscribe!
    covered.track('Unsubscribed', {
      'Organization'      => organization.id,
      'Organization Name' => organization.name,
    })

    organization_membership_record.unsubscribe!
  end

  def == other
    self.class === other && self.user_id == other.user_id && self.organization_id == other.organization_id
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization_id.inspect}, user_id: #{user_id.inspect}>)
  end

end