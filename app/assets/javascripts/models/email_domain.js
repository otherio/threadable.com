Threadable.EmailDomain = RL.Model.extend({
  id:               RL.attr('number'),
  organizationSlug: RL.attr('string'),
  domain:           RL.attr('string'),
  outgoing:         RL.attr('boolean'),
});

Threadable.RESTAdapter.map("Threadable.EmailDomain", {
  primaryKey: "id"
});

Threadable.EmailDomain.reopen(Threadable.AddOrganizationIdToRequestsMixin);
