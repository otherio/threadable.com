Covered.UngroupedConversationRoute = Ember.Route.extend({

  model: function(params){
    var conversation = this.modelFor('ungrouped_conversations').findBy('slug', params.conversation);
    conversation.loadMessages();
    return conversation;
  },

  setupController: function(controller, model) {
    this.controllerFor('conversation').set('model', model);
  },

  renderTemplate: function() {
    this.render('conversation', {into: 'organization', outlet: 'conversationPane'});
    this.controllerFor('organization').set('focus', 'conversation');
  }

});
