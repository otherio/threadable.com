Covered.Task = DS.Model.extend({
  param:      DS.attr('string'),
  slug:       DS.attr('string'),
  subject:    DS.attr('string'),
  position:   DS.attr('number'),
  done:       DS.attr('boolean'),

  created_at: DS.attr('date'),
  updated_at: DS.attr('date'),

  conversation: DS.hasMany('conversation', {async: true}),
  messages:     DS.hasMany('messages', {async: true}),
  doers:        DS.hasMany('members', {async: true})
});
