// This is a base class. We should never actually endup here
Covered.ComposeRoute = Ember.Route.extend({

  conversation: function(){ return Covered.Conversation.create(); },
  message:      function(){ return Covered.Message.create();      },
  groups:       function(){ return []; },

  setupController: function(controller, model) {
    this.controllerFor('navbar').set('composing', true);
    this.controllerFor('compose').setProperties({
      conversation: this.conversation(),
      message:      this.message(),
      groups:       this.groups()
    });
  },

  renderTemplate: function() {
    this.render('compose', {into: 'organization', outlet: 'conversationPane'});
    this.controllerFor('organization').set('focus', 'conversation');
  },

  actions: {
    willTransition: function() {
      this.controllerFor('navbar').set('composing', false);
    },
    transitionToConversation: function(conversation) {
      var routeName = this.routeName.replace('compose', 'conversation');
      this.transitionTo(routeName, conversation.get('slug'));
      // this.send('transitionUp', {refresh: true});
    }
  }

});
