Covered.ReplyController = Ember.ObjectController.extend({
  needs: ['conversation', 'organization', 'doerSelector'],

  message: Ember.computed.alias('model'),

  error: null,

  actions: {
    reset: function() {
      this.set('error', null);
      this.set('message.body', null);
    },
    sendMessage: function() {
      this.set('error', null);
      var organizationSlug = this.get('controllers.organization.content.slug');
      var conversation = this.get('controllers.conversation.model');

      var message = this.get('message');

      message.setProperties({
        organizationSlug: organizationSlug,
        conversationId:   conversation.get('id'),
        bodyPlain:        this.get('body'),
        bodyHtml:         this.get('bodyAsHtml'),
      });

      var newDoerIds = this.get('controllers.doerSelector.doers').map(function(doer) {
        return doer.get('id');
      }).sort();
      var oldDoerIds = conversation.get('doers').map(function(doer) {
        return doer.get('id');
      }).sort();

      if(Ember.compare(newDoerIds, oldDoerIds) != 0) {
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
        var body = message.get('body');
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
      }

      function onError(response){
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
      }
    }
  }
});
