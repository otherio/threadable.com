Covered.Conversation = RL.Model.extend({
  id:                RL.attr('number'),
  organizationSlug:  RL.attr('string'),
  slug:              RL.attr('string'),
  subject:           RL.attr('string'),
  task:              RL.attr('boolean'),
  createdAt:         RL.attr('date'),
  updatedAt:         RL.attr('date'),
  participantNames:  RL.attr('array'),
  numberOfMessages:  RL.attr('number'),
  messageSummary:    RL.attr('string'),
  groupIds:          RL.attr('array'),
  organizationId:    RL.attr('string'),
  doers:             RL.hasMany('Covered.User'),
  done:              RL.attr('boolean'),

  isTask: Ember.computed.alias('task'),
  isDone: Ember.computed.alias('done'),

  hasMessages: function() {
    return this.get('numberOfMessages') > 0;
  }.property('numberOfMessages'),

  loadEvents: RL.loadAssociationMethod('events', function(conversation){
    return Covered.Event.fetch({
      organization_id: conversation.get('organizationSlug'),
      conversation_id: conversation.get('slug')
    });
  }),

  participantNamesString: function() {
    return this.get('participantNames').join(', ');
  }.property('participantNames'),

  groups: function() {
    var groups = this.get('organization.groups');
    if (typeof groups === 'undefined') throw new Error('no groups. did you forget to set organization?');
    var groupIds = this.get('groupIds');
    if (!groupIds) return [];
    return groups.filter(function(group) {
      return groupIds.indexOf(group.get('id')) > -1;
    });
  }.property('groupIds','organization.groups'),


  myTask: function() {
    if (!this.get('isTask')) return false;
    var userId = Covered.currentUser.get('userId');
    var doers = this.get('doers');
    if (!doers) return false;
    var userIds = doers.mapBy('userId');
    return userIds.indexOf(userId) !== -1;
  }.property('isTask', 'doers')
});

Covered.RESTAdapter.map("Covered.Conversation", {
  primaryKey: "slug"
});


Covered.Conversation.reopen(Covered.AddOrganizationIdToRequestsMixin);
