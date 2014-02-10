//= require ./user

Threadable.GroupMember = Threadable.User.extend({
  organizationSlug: RL.attr('string'),
  personalMessage:  RL.attr('string'),
  getsInSummary:    RL.attr('boolean'),
  getsEveryMessage: RL.attr('boolean'),
});

Threadable.GroupMember.reopen(Threadable.AddOrganizationIdToRequestsMixin);
Threadable.GroupMember.reopen(Threadable.AddGroupIdToRequestsMixin);
