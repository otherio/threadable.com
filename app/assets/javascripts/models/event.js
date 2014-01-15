Covered.Event = RL.Model.extend({
  id:         RL.attr('number'),
  eventType:  RL.attr('string'),
  actor:      RL.attr('string'),
  doer:       RL.attr('string'),
  createdAt:  RL.attr('date'),
  message:    RL.belongsTo('Covered.Message'),

  display: function() {
    return this.get('eventType') != 'conversation_created';
  }.property('eventType'),
});

Covered.RESTAdapter.map("Covered.Event", {
  primaryKey: "slug"
});

Covered.Event.reopen(Covered.AddOrganizationIdToRequestsMixin);
