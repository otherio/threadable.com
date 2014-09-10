class Threadable::Organization::Settings < Threadable::Settings
  def initialize organization, settings
    @model = organization.organization_record
    @organization = organization
    super settings
  end

  attr_reader :organization

  def settable? setting
    settings[setting][:membership_required] == :free || organization.paid?
  end

  alias_method :gettable?, :settable?

end
