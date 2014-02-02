//= require ./user

Covered.OrganizationMember = Covered.User.extend({
  organizationSlug: RL.attr('string'),
  personalMessage:  RL.attr('string'),
});

Covered.OrganizationMember.reopen(Covered.AddOrganizationIdToRequestsMixin);
