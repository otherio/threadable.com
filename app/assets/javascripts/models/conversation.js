Covered.Conversation = RL.Model.extend({
  id:                RL.attr('number'),
  organizationSlug:  RL.attr('string'),
  slug:              RL.attr('string'),
  subject:           RL.attr('string'),
  task:              RL.attr('boolean'),
  createdAt:         RL.attr('date'),
  updatedAt:         RL.attr('date'),
  participantNames:  RL.attr('string'),
  numberOfMessages:  RL.attr('number'),
  messageSummary:    RL.attr('string'),
  groupIds:          RL.attr('string'),
  organizationId:    RL.attr('string'),

  hasMessages: function() {
    return this.get('numberOfMessages') > 0;
  }.property('numberOfMessages'),

  loadMessages: function() {
    var
      conversation = this,
      promise = conversation.get('loadMessagesPromise');
    if (promise) return promise;

    promise = Covered.Message.fetch({
      organization_id: conversation.get('organizationSlug'),
      conversation_id: conversation.get('slug')
    });

    promise.then(function(messages) {
      conversation.set('messages', messages);
    });
    conversation.set('loadMessagesPromise', promise);
    return promise;
  }
});

Covered.RESTAdapter.map("Covered.Conversation", {
  primaryKey: "slug"
});


Covered.Conversation.reopen(Covered.AddOrganizationIdToRequestsMixin);
