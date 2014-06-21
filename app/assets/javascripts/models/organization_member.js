//= require ./user

Threadable.OrganizationMember = Threadable.User.extend({
  organizationSlug:      RL.attr('string'),
  personalMessage:       RL.attr('string'),
  subscribed:            RL.attr('boolean'),
  role:                  RL.attr('string'),
  confirmed:             RL.attr('boolean'),

  isOwner: function() {
    return this.get('role') === 'owner';
  }.property('role'),

  isMember: function() {
    return this.get('role') === 'member';
  }.property('role'),

  isUnconfirmed: function() {
    return !this.get('confirmed');
  }.property('confirmed'),

});

Threadable.OrganizationMember.reopen(Threadable.AddOrganizationIdToRequestsMixin);
