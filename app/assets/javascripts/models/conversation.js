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

  hasMessages: function() {
    return this.get('numberOfMessages') > 0;
  }.property('numberOfMessages'),

  loadMessages: RL.loadAssociationMethod('messages', function(conversation){
    return Covered.Message.fetch({
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
  }.property('groupIds','organization.groups')
});

Covered.RESTAdapter.map("Covered.Conversation", {
  primaryKey: "slug"
});


Covered.Conversation.reopen(Covered.AddOrganizationIdToRequestsMixin);
