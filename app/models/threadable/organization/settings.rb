class Threadable::Organization::Settings < Threadable::Settings
  def initialize organization, settings
    @model = organization.organization_record
    @organization = organization
    @threadable = organization.threadable
    super settings
  end

  attr_reader :organization

  def settable? setting
    raise Threadable::AuthorizationError, 'You do not have permission to change settings on this organization' unless organization.members.current_member && organization.members.current_member.can?(:change_settings_for, organization)
    accessible? setting
  end

  def gettable? setting
    accessible? setting
  end

  private

  def accessible? setting
    settings[setting][:membership_required] == :free || organization.paid?
  end

end
