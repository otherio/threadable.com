Threadable.ComposeController = Ember.Controller.extend({
  needs: ['organization', 'group', 'topbar'],

  organization: Ember.computed.alias('controllers.organization'),

  sending: false,
  conversation: null,
  message: null,
  groups: Ember.ArrayProxy.create({content:[]}),
  isTask: false,
  subject: null,
  body: null,
  error: null,

  unselectedGroups: function() {
    var groups = Ember.ArrayProxy.create({content:[]});
    groups.addObjects(this.get('organization.groups'));
    groups.removeObjects(this.get('groups'));
    return groups;
  }.property('allGroups.length', 'groups.length'),

  addGroup: function(group) {
    var groups = this.get('groups');
    if (typeof group === 'string') group = this.get('organization.groups').findBy('slug', group);
    if (!group) return;
    if (groups.indexOf(group) === -1) groups.pushObject(group);
  },

  hasSubject: function() {
    var subject = this.get('subject');
    return subject && !subject.match(/^(\s|\n)+$/);
  }.property('subject'),

  disabled: function(){
    return this.get('sending') || !this.get('hasSubject');
  }.property('sending', 'hasSubject'),

  actions: {
    reset: function() {
      this.get('groups').clear();
      this.addGroup(this.get('controllers.group.model'));
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
    removeGroup: function(group) {
      this.get('groups').removeObject(group);
    },
    addGroup: function(group) {
      this.get('groups').addObject(group);
    },
    sendMessage: function() {
      if (this.get('disabled')) return;
      this.set('sending', true);
      var
        organization     = this.get('organization'),
        organizationSlug = organization.get('slug'),
        conversation     = Threadable.Conversation.create(),
        message          = Threadable.Message.create(),
        subject          = this.get('subject'),
        isTask           = this.get('isTask'),
        groups           = this.get('groups').toArray();

      conversation.set('subject', subject);
      conversation.set('organizationSlug', organizationSlug);
      conversation.set('groupIds', groups.mapBy('id'));
      conversation.set('task', isTask);

      message.set('organizationSlug', organizationSlug);
      message.set('subject', subject);
      message.set('body', this.get('body'));
      message.set('bodyPlain', this.get('body'));
      message.set('bodyHtml', message.get('bodyAsHtml'));

      conversation.saveRecord().then(
        conversationSaved.bind(this),
        conversationFailed.bind(this)
      );

      function conversationSaved(response) {
        message.set('conversationId',   conversation.get('id'));
        message.set('conversationSlug', conversation.get('slug'));
        if(conversation.get('isTask') && !message.get('body')) {
          // don't send messages for blank tasks.
          saveFinished.bind(this)();
          return;
        }

        message.saveRecord().then(
          messageSaved.bind(this),
          messageFailed.bind(this)
        );
      }

      function conversationFailed(xhr) {
        error.call(this, xhr);
        this.set('sending', false);
      }

      function messageSaved(response) {
        conversation.deserialize(response.message.conversation);
        saveFinished.bind(this)();
      }

      function saveFinished() {
        conversation.set('organization', organization);
        Threadable.Conversation.cache(conversation);
        this.send('reset');
        this.send('addConversation', conversation);
        this.send('transitionToConversation', conversation);
        this.set('sending', false);
      }

      function messageFailed(xhr) {
        error.call(this, xhr);
        conversation.deleteRecord();
        conversation.set('id', null);
        conversation.set('slug', null);
        conversation.set('isNew', true);
        this.set('sending', false);
      }

      function error(response) {
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
      }

    }
  }
});
