Covered.Conversation = RL.Model.extend({
  id:                RL.attr('number'),
  param:             RL.attr('string'),
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
  }.property('numberOfMessages')
});

Covered.RESTAdapter.map("Covered.Conversation", {
  primaryKey: "slug"
});

