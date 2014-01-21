Covered.User = RL.Model.extend({
  id:           RL.attr('string'),
  userId:       RL.attr('number'),
  param:        RL.attr('string'),
  name:         RL.attr('string'),
  emailAddress: RL.attr('string'),
  slug:         RL.attr('string'),
  avatarUrl:    RL.attr('string')
});

Covered.Member = Covered.User.extend({
  organizationSlug: RL.attr('string'),
  personalMessage:  RL.attr('string')
});

Covered.Member.reopen(Covered.AddOrganizationIdToRequestsMixin);
