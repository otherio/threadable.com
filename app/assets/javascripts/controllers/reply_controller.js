Covered.ReplyController = Ember.ObjectController.extend({
  needs: ['conversation', 'organization', 'doerSelection'],

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

      var newDoerIds = this.get('controllers.doerSelection.doers').map(function(doer) {
        return doer.get('id');
      }).sort();
      var oldDoerIds = conversation.get('doers').map(function(doer) {
        return doer.get('id');
      }).sort();

      if(newDoerIds != oldDoerIds) {
        var newDoers = RL.RecordArray.createWithContent();
        this.get('controllers.doerSelection.doers').forEach(function(doer) {
          newDoers.pushObject(doer);
        });
        conversation.set('doers', newDoers);
        conversation.saveRecord().then(onDoersSuccess.bind(this), onError.bind(this));
      } else {
        message.saveRecord().then(onMessageSuccess.bind(this), onError.bind(this));
      }

      function onDoersSuccess(response) {
        message.saveRecord().then(onMessageSuccess.bind(this), onError.bind(this));
        conversation.get('doers').deserializeMany(response.conversation.doers);
        this.get('controllers.doerSelection').set('doers', conversation.get('doers').toArray());
        conversation.loadEvents(true);
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
