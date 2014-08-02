Threadable.Message = RL.Model.extend({
  id:               RL.attr('number'),
  conversationId:   RL.attr('number'),
  organizationId:   RL.attr('string'),
  conversationSlug: RL.attr('string'),
  organizationSlug: RL.attr('string'),
  uniqueId:         RL.attr('string'),
  from:             RL.attr('string'),
  subject:          RL.attr('string'),
  body:             RL.attr('string'),
  bodyStripped:     RL.attr('string'),
  bodyPlain:        RL.attr('string'),
  bodyHtml:         RL.attr('string'),
  messageIdHeader:  RL.attr('string'),
  referencesHeader: RL.attr('string'),
  dateHeader:       RL.attr('date'),
  html:             RL.attr('boolean'),
  root:             RL.attr('string'),
  shareworthy:      RL.attr('string'),
  knowledge:        RL.attr('string'),
  createdAt:        RL.attr('date'),
  sentAt:           RL.attr('date'),
  sentToYou:        RL.attr('boolean'),
  parentMessageId:  RL.attr('number'),
  avatarUrl:        RL.attr('string'),
  senderName:       RL.attr('string'),
  attachments:      RL.attr('object'),

  hasQuotedText: function() {
    return this.get('body') != this.get('bodyStripped');
  }.property('body', 'bodyStripped'),

  bodyAsHtml: function() {
    var body = this.get('body');

    if(body){
      body = Threadable.htmlEscape(body);
      return '<p>' + body.replace(/\n/g, "<br />\n") + '</p>';
    }
  }.property('body'),

  bodyWithAttachmentsInline: function() {
    return Threadable.replaceAttachmentContentIdsWithAttachmentUrls(this.get('body'), this.get('attachments'));
  }.property('attachments', 'body'),

  bodyStrippedWithAttachmentsInline: function() {
    return Threadable.replaceAttachmentContentIdsWithAttachmentUrls(this.get('bodyStripped'), this.get('attachments'));
  }.property('attachments', 'bodyStripped'),

});

Threadable.replaceAttachmentContentIdsWithAttachmentUrls = function(body, attachments) {
  attachments.forEach(function(attachment){
    if(!attachment.content_id) { return; }
    var content_id = attachment.content_id.slice(1,-1);
    if (content_id) body = body.replace('cid:'+content_id, attachment.url);
  });
  return body;
};

Threadable.RESTAdapter.map("Threadable.Message", {
  primaryKey: "slug"
});

Threadable.Message.reopen(Threadable.AddOrganizationIdToRequestsMixin);
