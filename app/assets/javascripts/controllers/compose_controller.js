Covered.ComposeController = Ember.Controller.extend({
  needs: ['organization', 'group', 'navbar'],

  organization: Ember.computed.alias('controllers.organization'),

  conversation: null,
  message: null,
  groups: Ember.ArrayProxy.create({content:[]}),
  isTask: false,
  subject: null,
  body: null,
  error: null,

  addGroup: function(group) {
    var groups = this.get('groups');
    if (typeof group === 'string') group = this.get('organization.groups').findBy('slug', group);
    if (!group) return;
    if (groups.indexOf(group) === -1) groups.pushObject(group);
  },

  actions: {
    reset: function() {
      this.get('groups').clear();
      this.addGroup(this.get('controllers.group.model'));
      this.set('subject', null);
      this.set('bodyHtml', null);
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
        organization     = this.get('organization'),
        organizationSlug = organization.get('slug'),
        conversation     = Covered.Conversation.create(),
        message          = Covered.Message.create(),
        subject          = this.get('subject'),
        isTask           = this.get('isTask'),
        groups           = this.get('groups').toArray();

      conversation.set('subject', subject);
      conversation.set('organizationSlug', organizationSlug);
      conversation.set('groupIds', groups.mapBy('id'));
      conversation.set('task', isTask);

      message.setProperties({
        organizationSlug: organizationSlug,
        subject:          subject,
        bodyHtml:         this.get('bodyHtml'),
        html:             true
      });

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
        conversation.deserialize(response.message.conversation);
        conversation.set('organization', organization);
        Covered.Conversation.cache(conversation);
        this.send('reset');
        this.send('addConversation', conversation);
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
