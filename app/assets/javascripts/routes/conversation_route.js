Covered.ConversationRoute = Ember.Route.extend({

  model: function(params){
    var conversation = this.modelFor('conversations').findBy('slug', params.conversation);
    conversation.loadMessages();
    return conversation;
    // return conversation.loadMessages().then(function(){ return conversation });
  },

  renderTemplate: function() {
    this.render('conversation', {into: 'organization', outlet: 'conversationPane'});
    this.controllerFor('organization').set('focus', 'conversation');
  },

  actions: {
    willTransition: function(transition) {
      this.controllerFor('conversation').set('model', null);
    }
  }

});
