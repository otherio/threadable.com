Covered.ComposeController = Ember.ObjectController.extend({
  needs: ['organization', 'group'],

  currentOrganization: Ember.computed.alias('controllers.organization'),
  currentGroup:        Ember.computed.alias('controllers.group'),

  composingTask: function() {
    return this.get('composing') == 'task';
  }.property('composing'),

  composingConversation: function() {
    return this.get('composing') == 'conversation';
  }.property('composing'),

  actions: {
    sendMessage: function() {
      var organizationSlug = this.get('controllers.organization').get('content').get('slug');
      var groupSlug = this.get('controllers.group').get('content').get('slug');

      var message = this.get('content');
      var isTask = message.get('composing') === 'task';
      var conversation = Covered.Conversation.create({
        subject: this.get('subject'),
        organizationId: organizationSlug,
        groupIds: groupSlug, // eventually this will be settable in the UI
        task: isTask
      });

      conversation.saveRecord().then(function(response) {
        message.set('conversationId', response.conversation.slug);
        message.set('organizationId', organizationSlug);

        message.saveRecord().then(function(response) {
          this.transitionToRoute('conversations', organizationSlug, groupSlug);
        }.bind(this), function(response){
          console.log('we would handle an error in saving the message here: ', response);
        });
      }.bind(this), function(response) {
        console.log('we would handle an error in saving the conversation here: ', response);
      });
    }
  }
});
