Covered.Message = RL.Model.extend({
  id:               RL.attr('number'),
  uniqueId:         RL.attr('string'),
  from:             RL.attr('string'),
  subject:          RL.attr('string'),
  body:             RL.attr('string'),
  bodyStripped:     RL.attr('string'),
  messageIdHeader:  RL.attr('string'),
  referencesHeader: RL.attr('string'),
  dateHeader:       RL.attr('date'),
  html:             RL.attr('string'),
  root:             RL.attr('string'),
  shareworthy:      RL.attr('string'),
  knowledge:        RL.attr('string'),
  createdAt:        RL.attr('date'),
  parentMessageId:  RL.attr('number'),
  avatarUrl:        RL.attr('string'),
  senderName:       RL.attr('string'),

  conversationId:   RL.attr('string'),
  organizationId:   RL.attr('string'),
  groupId:          RL.attr('string'),

  hasQuotedText: function() {
    return this.get('body') != this.get('bodyStripped');
  }.property('body', 'bodyStripped')
});

Covered.RESTAdapter.map("Covered.Message", {
  primaryKey: "slug"
});

