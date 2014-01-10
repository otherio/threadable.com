Covered.Message = DS.Model.extend({
  uniqueId:         DS.attr('string'),
  from:             DS.attr('string'),
  subject:          DS.attr('string'),

  body:             DS.attr('string'),
  bodyStripped:     DS.attr('string'),

  messageIdHeader:  DS.attr('string'),
  referencesHeader: DS.attr('string'),
  dateHeader:       DS.attr('date'),

  html:             DS.attr('boolean'),
  root:             DS.attr('boolean'),
  shareworthy:      DS.attr('boolean'),
  knowledge:        DS.attr('boolean'),
  createdAt:        DS.attr('date'),

  parentMessageId:  DS.attr('number'),

  conversation:     DS.belongsTo('conversation')
});

Covered.MessageAdapter = DS.CoveredAdapter.extend({
  urlFormat: '/organizations/:organization_id/conversations/:conversation_id/messages'
});
