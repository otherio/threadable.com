Threadable.EmailDomain = RL.Model.extend({
  id:         RL.attr('number'),
  domain:     RL.attr('string'),
  outgoing:   RL.attr('boolean'),
});

Threadable.RESTAdapter.map("Threadable.EmailDomain", {
  primaryKey: "domain"
});

Threadable.EmailDomain.reopen(Threadable.AddOrganizationIdToRequestsMixin);
