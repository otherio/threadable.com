// This is a base class. We should never actually endup here
Covered.ConversationRoute = Ember.Route.extend({

  parentRouteName: null,

  model: function(params){
    var conversations = this.modelFor(this.get('parentRouteName'));
    var conversation = conversations.findBy('slug', params.conversation);
    conversation.loadEvents();
    return conversation;
  },

  setupController: function(controller, model) {
    this.controllerFor('conversation').set('model', model);
    this.controllerFor('reply').set('model', Covered.Message.create({}));
  },

  renderTemplate: function() {
    this.render('conversation', {into: 'organization', outlet: 'conversationPane'});
    this.render('reply', {into: 'conversation', outlet: 'reply'});
    this.controllerFor('organization').set('focus', 'conversation');
  },

  actions: {
    willTransition: function(transition) {
      this.controllerFor('conversation').set('model', null);
    }
  }

});
