require_dependency 'covered/organization'

class Covered::Organization::Update < MethodObject

  def call organization, attributes
    !!organization.organization_record.update_attributes(attributes)
  end

end
