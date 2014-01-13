Covered.MyConversationRoute = Ember.Route.extend({

  model: function(params){
    var conversation = this.modelFor('my_conversations').findBy('slug', params.conversation);
    conversation.loadMessages();
    return conversation;
  },

  setupController: function(controller, model) {
    this.controllerFor('conversation').set('model', model);
    this.controllerFor('navbar').set('group', null);
    this.controllerFor('navbar').set('conversation', model);
  },

  renderTemplate: function() {
    this.render('conversation', {into: 'organization', outlet: 'conversationPane'});
    this.controllerFor('organization').set('focus', 'conversation');
  }

});
