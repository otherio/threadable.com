// This is a base class. We should never actually endup here
Covered.ConversationsIndexRoute = Ember.Route.extend({

  setupController: function(controller, model) {
    this.controllerFor('navbar').set('conversation', null);
    this.controllerFor('organization').set('focus', 'conversations');
  }

});
