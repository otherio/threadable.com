Threadable.ReplyController = Ember.ObjectController.extend({
  needs: ['conversation', 'organization', 'doerSelector'],

  message: Ember.computed.alias('model'),
  doerSelector: Ember.computed.alias('controllers.doerSelector'),
  sending: false,

  error: null,

  disabled: function() {
    return this.get('sending') || (!this.get('hasBody') && !this.get('changedDoers'));
  }.property('sending', 'hasBody', 'changedDoers'),

  buttonText: function() {
    if(!this.get('controllers.conversation.isTask')) {
      return 'Send';
    }

    var changedDoers = this.get('changedDoers');
    var hasBody = this.get('hasBody');

    if(hasBody && changedDoers) {
      return 'Send & Update';
    } else if(hasBody) {
      return 'Send';
    } else if(changedDoers) {
      return 'Update Doers';
    } else {
      return 'Send';
    }
  }.property('hasBody', 'changedDoers'),

  changedDoers: function() {
    return !!this.get('doerSelector').filterBy('isChanged', true).length;
  }.property('doerSelector.@each.isChanged'),

  hasBody: function() {
    var body = this.get('body');
    return body && !body.match(/^(\s|\n)+$/);
  }.property('body'),

  actions: {
    reset: function() {
      this.set('error', null);
      this.set('message.body', null);
    },
    sendMessage: function() {
      if (this.get('disabled')) return;
      this.set('sending', true);
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
        this.set('sending', false);
      }

      function saveMessage() {
        message.saveRecord().then(onMessageSuccess.bind(this), onError.bind(this));
      }

      function onMessageSuccess(response) {
        conversation.deserialize(response.message.conversation);

        var message = this.get('content');
        var event = Threadable.Event.create({
          id:        'message-' + message.get('id'),
          eventType: 'created_message',
          createdAt: message.get('sentAt'),
          message:   message,
        });

        conversation.get('events').pushObject(event);
        this.set('content', Threadable.Message.create({}));
        this.set('sending', false);
      }

      function onError(response){
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
        this.set('sending', false);
      }
    }
  }
});
