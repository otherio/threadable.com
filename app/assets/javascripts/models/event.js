Threadable.Event = RL.Model.extend({
  id:         RL.attr('number'),
  eventType:  RL.attr('string'),
  actor:      RL.attr('string'),
  doer:       RL.attr('string'),
  group:      RL.attr('string'),
  createdAt:  RL.attr('date'),
  message:    RL.belongsTo('Threadable.Message'),

  display: function() {
    return this.get('eventType') != 'conversation_created';
  }.property('eventType'),
});

Threadable.RESTAdapter.map("Threadable.Event", {
  primaryKey: "id"
});

Threadable.Event.reopen(Threadable.AddOrganizationIdToRequestsMixin);
