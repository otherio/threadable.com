require_dependency 'threadable/organization/member'

class Threadable::Organization::Member::Update < MethodObject

  ATTRIBUTES = [:gets_email, :confirmed, :subscribed, :role].freeze

  attr_reader :threadable, :current_user, :current_member, :member, :attributes

  def call member, attributes
    @current_user = member.threadable.current_user
    @current_member = member.organization.members.current_member
    @member = member
    @attributes = attributes.slice(*ATTRIBUTES)
    @attributes[:subscribed] = @attributes.delete(:gets_email) if @attributes.key?(:gets_email)
    @threadable = member.threadable
    update_organization_membership_record!
  end

  def update_organization_membership_record!
    record = member.organization_membership_record

    if attributes[:role].present? && attributes[:role].to_sym != record.role && !current_user.admin?
      if !current_member.can?(:make_owners_for, member.organization)
        raise Threadable::AuthorizationError, 'You are not authorized to change organization membership roles'
      end
      if current_member == member
        raise Threadable::AuthorizationError, 'You cannot change your own organization membership role'
      end
    end

    if attributes.has_key?(:subscribed) && attributes[:subscribed] != record.subscribed? && !current_user.admin?
      unless current_member.can?(:change_delivery_for, member)
        raise Threadable::AuthorizationError, 'You cannot change subscription settings for this member'
      end
    end

    original_values = {
      subscribed:              record.subscribed?,
      role:                    record.role,
    }

    record.attributes = attributes
    return unless record.changed?

    record.save!

    if record.subscribed? != original_values[:subscribed]
      track(member.subscribed? ? 'Re-subscribed' : 'Unsubscribed')
    end

    if record.role != original_values[:role]
      track('Organization membership role changed', {
        'from' => original_values[:role],
        'to'   => record.role,
      });
    end

  end


  def track event, options={}
    threadable.track(event, {
      'Member user id'    => member.user_id,
      'Organization'      => member.organization.id,
      'Organization Name' => member.organization.name,
    }.merge(options))
  end

end
