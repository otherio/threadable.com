//= require ./user

Threadable.OrganizationMember = Threadable.User.extend({
  organizationSlug: RL.attr('string'),
  personalMessage:  RL.attr('string'),
});

Threadable.OrganizationMember.reopen(Threadable.AddOrganizationIdToRequestsMixin);
