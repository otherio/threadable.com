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
    return this.inlineAttachments(this.get('body'));
  }.property('body'),

  bodyStrippedWithAttachmentsInline: function() {
    return this.inlineAttachments(this.get('bodyStripped'));
  }.property('bodyStripped'),

  inlineAttachments: function(body) {
    var attachments = this.get('attachments');
    if(attachments.length > 0) {
      $.each(attachments, function(offset, attachment) {
        var cid = attachment.content_id;
        if(!cid)
          return;

        cid = cid.replace(/[<>]/, '');
        body = body.replace('cid:' + cid, attachment.url);
      });
    }
    return body;
  }
});

Threadable.RESTAdapter.map("Threadable.Message", {
  primaryKey: "slug"
});

Threadable.Message.reopen(Threadable.AddOrganizationIdToRequestsMixin);
