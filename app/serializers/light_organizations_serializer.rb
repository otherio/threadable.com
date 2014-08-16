class LightOrganizationsSerializer < Serializer
  self.singular_record_name = :organization
  self.plural_record_name = :organizations

  def serialize_record organization
    {
      id:                organization.id,
      param:             organization.to_param,
      name:              organization.name,
      short_name:        organization.short_name,
      slug:              organization.slug,
      subject_tag:       organization.subject_tag,
      description:       organization.description,
      trusted:           organization.trusted?,
      plan:              organization.plan,
    }
  end
end
