Covered.Group = DS.Model.extend({
  param:             DS.attr('string'),
  slug:              DS.attr('string'),
  name:              DS.attr('string'),
  email_address_tag: DS.attr('string'),
  color:             DS.attr('string'),

  email_address:                DS.attr('string'),
  task_email_address:           DS.attr('string'),
  formatted_email_address:      DS.attr('string'),
  formatted_task_email_address: DS.attr('string'),

  conversations_count: DS.attr('number'),

  members:       DS.hasMany('group', {async:true}),
  conversations: DS.hasMany('conversation', {async:true}),
  tasks:         DS.hasMany('conversation', {async:true}),

  badgeStyle: function() {
    return "background-color: "+this.get('color')+";";
  }.property('color')
});

Covered.GroupAdapter = DS.CoveredAdapter.extend({
});
