Covered.GroupConversationRoute = Ember.Route.extend({

  model: function(params){
    var conversation = this.modelFor('group_conversations').findBy('slug', params.conversation);
    conversation.loadMessages();
    return conversation;
    // return conversation.loadMessages().then(function(){ return conversation });
  },

  setupController: function(controller, model) {
    this.controllerFor('conversation').set('model', model);
    this.controllerFor('navbar').set('conversation', model);
  },

  renderTemplate: function() {
    this.render('conversation', {into: 'organization', outlet: 'conversationPane'});
    this.controllerFor('organization').set('focus', 'conversation');
  },

  actions: {
    willTransition: function(transition) {
      this.controllerFor('conversation').set('model', null);
      this.controllerFor('navbar').set('conversation', null);
    }
  }

});
