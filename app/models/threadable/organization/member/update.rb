require_dependency 'threadable/organization/member'

class Threadable::Organization::Member::Update < MethodObject

  attr_reader :threadable, :member, :attributes

  def call member, attributes
    @member = member
    @attributes = attributes
    @threadable = member.threadable
    update_organization_membership_record!
  end

  def update_organization_membership_record!
    record = member.organization_membership_record
    original_values = {
      subscribed:              record.subscribed?,
      ungrouped_mail_delivery: record.ungrouped_mail_delivery,
    }

    record.attributes = attributes.slice(:subscribed, :ungrouped_mail_delivery)
    return unless record.changed?

    record.save!

    if record.subscribed? != original_values[:subscribed]
      track(member.subscribed? ? 'Re-subscribed' : 'Unsubscribed')
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
