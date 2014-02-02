//= require ./user

Covered.GroupMember = Covered.User.extend({
  organizationSlug: RL.attr('string'),
  personalMessage:  RL.attr('string'),
});

Covered.GroupMember.reopen(Covered.AddOrganizationIdToRequestsMixin);
