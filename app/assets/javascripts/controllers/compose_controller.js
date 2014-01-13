Covered.ComposeController = Ember.ObjectController.extend({
  needs: ['organization', 'navbar'],

  organization: Ember.computed.alias('controllers.organization'),

  conversation: null,
  message: null,
  groups: null,
  isTask: false,
  subject: null,
  body: null,
  error: null,

  addGroup: function(group) {
    var groups = this.get('groups') || [];
    if (groups.indexOf(group) === -1) groups.push(group);
    this.set('groups', groups);
  },

  actions: {
    reset: function() {
      this.set('subject', null);
      this.set('body', null);
      this.set('error', null);
    },
    composeTask: function() {
      this.set('isTask', true);
    },
    composeConversation: function() {
      this.set('isTask', false);
    },
    sendMessage: function() {
      var
        conversation     = this.get('conversation'),
        message          = this.get('message'),
        subject          = this.get('subject'),
        body             = this.get('body'),
        organizationSlug = this.get('organization').get('slug'),
        isTask           = this.get('isTask'),
        groups           = this.get('groups') || [];

      conversation.set('subject', subject);
      conversation.set('organizationSlug', organizationSlug);
      conversation.set('groupIds', groups.mapBy('id'));
      conversation.set('task', isTask);

      message.set('organizationSlug', organizationSlug);
      message.set('subject', subject);
      message.set('body', body);

      conversation.saveRecord().then(
        conversationSaved.bind(this),
        conversationFailed.bind(this)
      );

      function conversationSaved(response) {
        message.set('conversationId',   conversation.get('id'));
        message.set('conversationSlug', conversation.get('slug'));
        message.saveRecord().then(
          messageSaved.bind(this),
          messageFailed.bind(this)
        );
      }

      function conversationFailed(xhr) {
        error.call(this, xhr);
      }

      function messageSaved(response) {
        conversation.set('numberOfMessages', 1);
        this.send('reset');
        this.send('prependConversation', conversation);
        this.send('transitionToConversation', conversation);
      }

      function messageFailed(xhr) {
        error.call(this, xhr);
        conversation.deleteRecord();
        conversation.set('id', null);
        conversation.set('slug', null);
        conversation.set('isNew', true);
      }

      function error(response) {
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
      }

    }
  }
});
