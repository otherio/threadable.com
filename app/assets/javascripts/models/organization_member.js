//= require ./user

Threadable.OrganizationMember = Threadable.User.extend({
  organizationSlug:      RL.attr('string'),
  personalMessage:       RL.attr('string'),
  subscribed:            RL.attr('boolean'),
  role:                  RL.attr('string'),
  ungroupedMailDelivery: RL.attr('string'),

  getsNoUngroupedMail: function() {
    return this.get('ungroupedMailDelivery') == 'no_mail';
  }.property('ungroupedMailDelivery'),

  getsEachUngroupedMessage: function() {
    return this.get('ungroupedMailDelivery') == 'each_message';
  }.property('ungroupedMailDelivery'),

  getsUngroupedInSummary: function() {
    return this.get('ungroupedMailDelivery') == 'in_summary';
  }.property('ungroupedMailDelivery'),

});

Threadable.OrganizationMember.reopen(Threadable.AddOrganizationIdToRequestsMixin);
