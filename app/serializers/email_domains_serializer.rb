class EmailDomainsSerializer < Serializer

  def serialize_record email_domain
    {
      id:                email_domain.id,
      organization_slug: email_domain.organization.slug,
      domain:            email_domain.domain,
      outgoing:          email_domain.outgoing?,
    }
  end
end
