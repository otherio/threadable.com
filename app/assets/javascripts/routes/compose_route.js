Threadable.ComposeRoute = Ember.Route.extend({

  setupController: function(controller, context, transition) {
    this.controllerFor('organization').set('focus', 'conversation');
    this.controllerFor('topbar').set('composing', true);
    this.controllerFor('compose').get('groups').clear();
    this.controllerFor('compose').addGroup(this.modelFor('group'));
  },

  renderTemplate: function() {
    this.render('compose', {into: 'organization', outlet: 'pane2'});
  },

  actions: {
    willTransition: function() {
      this.controllerFor('topbar').set('composing', false);
      $("#inputWithFocus").blur();
    },
    transitionToConversation: function(conversation) {
      var routeName = this.routeName.replace('compose_','');
      this.transitionTo(routeName, conversation.get('slug'));
    }
  }

});
