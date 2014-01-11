Covered.Conversation = RL.Model.extend({
  id:                 RL.attr('number'),
  param:              RL.attr('string'),
  slug:               RL.attr('string'),
  subject:            RL.attr('string'),
  task:               RL.attr('string'),
  created_at:         RL.attr('date'),
  updated_at:         RL.attr('date'),
  participant_names:  RL.attr('string'),
  number_of_messages: RL.attr('number'),
  message_summary:    RL.attr('string'),
  group_ids:          RL.attr('string'),
  organization_id:    RL.attr('string'),

  hasMessages: function() {
    // return this.get('numberOfMessages') > 0;
    return true;
  }.property('number_of_messages')
});

Covered.RESTAdapter.map("Covered.Conversation", {
  primaryKey: "slug"
});

