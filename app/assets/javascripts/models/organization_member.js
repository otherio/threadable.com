//= require ./user

Threadable.OrganizationMember = Threadable.User.extend({
  organizationSlug: RL.attr('string'),
  personalMessage:  RL.attr('string'),
  isSubscribed:     RL.attr('boolean'),

});

Threadable.OrganizationMember.reopen(Threadable.AddOrganizationIdToRequestsMixin);
