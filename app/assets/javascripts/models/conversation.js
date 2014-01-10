Covered.Conversation = DS.Model.extend({
  slug:       DS.attr('string'),
  subject:    DS.attr('string'),
  task:       DS.attr('boolean'),
  created_at: DS.attr('date'),
  updated_at: DS.attr('date'),

  numberOfMessages: DS.attr('number'),
  participantNames: DS.attr('object'),
  messageSummary:   DS.attr('string'),

  group_ids: DS.attr('object'),

  organization: DS.belongsTo('organization', {async: true}),
  messages: DS.hasMany('message', {async: true}),

  hasMessages: function(){
    return this.get('numberOfMessages') > 0;
  }.property('numberOfMessages')
});
