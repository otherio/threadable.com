//= require ./user

Threadable.GroupMember = Threadable.User.extend({
  organizationSlug: RL.attr('string'),
  personalMessage:  RL.attr('string'),
  inSummary:        RL.attr('boolean'),
});

Threadable.GroupMember.reopen(Threadable.AddOrganizationIdToRequestsMixin);
Threadable.GroupMember.reopen(Threadable.AddGroupIdToRequestsMixin);
