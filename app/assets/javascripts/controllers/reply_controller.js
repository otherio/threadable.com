Covered.ReplyController = Ember.ObjectController.extend({
  needs: ['conversation', 'organization', 'doerSelector'],

  message: Ember.computed.alias('model'),
  doerSelector: Ember.computed.alias('controllers.doerSelector'),

  error: null,

  emptyAction: function() {
    return !this.get('hasText') && !this.get('changedDoers');
  }.property('hasText', 'changedDoers'),

  buttonText: function() {
    if(!this.get('controllers.conversation.isTask')) {
      return 'Send';
    }

    var changedDoers = this.get('changedDoers');
    var hasText = this.get('hasText');

    if(hasText && changedDoers) {
      return 'Send & Update';
    } else if(hasText) {
      return 'Send';
    } else if(changedDoers) {
      return 'Update Doers';
    } else {
      return 'Send/Update Doers';
    }
  }.property('hasText', 'changedDoers'),

  changedDoers: function() {
    return !!this.get('doerSelector').filterBy('isChanged', true).length;
  }.property('doerSelector.@each.isChanged'),

  hasText: function() {
    return !!this.get('bodyHtml');
  }.property('bodyHtml'),

  actions: {
    reset: function() {
      this.set('error', null);
      this.set('bodyHtml', null);
    },
    sendMessage: function() {
      this.set('error', null);
      var organizationSlug = this.get('controllers.organization.content.slug');
      var conversation = this.get('controllers.conversation.model');

      var message = this.get('message');

      message.setProperties({
        organizationSlug: organizationSlug,
        conversationId:   conversation.get('id'),
        bodyHtml:         this.get('bodyHtml'),
        html:             true
      });

      if(this.get('changedDoers')) {
        var newDoers = RL.RecordArray.createWithContent();
        this.get('controllers.doerSelector.doers').forEach(function(doer) {
          newDoers.pushObject(doer);
        });
        conversation.set('doers', newDoers);
        conversation.saveRecord().then(onDoersSuccess.bind(this), onError.bind(this));
      } else {
        saveMessage.bind(this)();
      }

      function onDoersSuccess(response) {
        saveMessage.bind(this)();
        conversation.get('doers').deserializeMany(response.conversation.doers);
        this.get('controllers.doerSelector').set('doers', conversation.get('doers').toArray());
        conversation.loadEvents(true);
      }

      function saveMessage() {
        var body = message.get('bodyHtml');
        if(body && body.match(/\w/)){
          message.saveRecord().then(onMessageSuccess.bind(this), onError.bind(this));
        }
      }

      function onMessageSuccess(response) {
        conversation.deserialize(response.message.conversation);

        var message = this.get('content');
        var event = Covered.Event.create({
          id:        'message-' + message.get('id'),
          eventType: 'created_message',
          createdAt: message.get('sentAt'),
          message:   message,
        });

        conversation.get('events').pushObject(event);
        this.set('content', Covered.Message.create({}));
        this.send('reset');
      }

      function onError(response){
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
      }
    }
  }
});
