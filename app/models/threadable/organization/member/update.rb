require_dependency 'threadable/organization/member'

class Threadable::Organization::Member::Update < MethodObject

  ATTRIBUTES = [:subscribed, :role, :ungrouped_mail_delivery].freeze

  attr_reader :threadable, :current_member, :member, :attributes

  def call member, attributes
    @current_member = member.organization.members.current_member
    @member = member
    @attributes = attributes.slice(:subscribed, :role, :ungrouped_mail_delivery)
    @threadable = member.threadable
    update_organization_membership_record!
  end

  def update_organization_membership_record!
    record = member.organization_membership_record
    original_values = {
      subscribed:              record.subscribed?,
      role:                    record.role,
      ungrouped_mail_delivery: record.ungrouped_mail_delivery,
    }

    if record.role != original_values[:role]
      if !current_member.can?(:make_owners_for, @member.organization)
        raise Threadable::AuthorizationError, 'You are not authorized to change organization membership roles'
      end
      if current_member == member
        raise Threadable::AuthorizationError, 'You cannot change your own organization membership role'
      end
    end

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

    if record.ungrouped_mail_delivery != original_values[:ungrouped_mail_delivery]
      track('Ungrouped mail delivery changed', {
        'from' => original_values[:ungrouped_mail_delivery],
        'to'   => record.ungrouped_mail_delivery,
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
