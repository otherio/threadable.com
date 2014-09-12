//= require ./user

Threadable.GroupMember = Threadable.User.extend({
  organizationSlug:  RL.attr('string'),
  personalMessage:   RL.attr('string'),
  deliveryMethod:    RL.attr('string'),
  canChangeDelivery: RL.attr('boolean'),

  getsEachMessage: function() {
    return this.get('deliveryMethod') == 'gets_each_message';
  }.property('deliveryMethod'),

  getsInSummary: function() {
    return this.get('deliveryMethod') == 'gets_in_summary';
  }.property('deliveryMethod'),

  getsFirstMessage: function() {
    return this.get('deliveryMethod') == 'gets_first_message';
  }.property('deliveryMethod')
});

Threadable.GroupMember.reopen(Threadable.AddOrganizationIdToRequestsMixin);
Threadable.GroupMember.reopen(Threadable.AddGroupIdToRequestsMixin);
