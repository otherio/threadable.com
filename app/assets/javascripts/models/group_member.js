//= require ./user

Threadable.GroupMember = Threadable.User.extend({
  organizationSlug: RL.attr('string'),
  personalMessage:  RL.attr('string'),
});

Threadable.GroupMember.reopen(Threadable.AddOrganizationIdToRequestsMixin);
