//= require ../conversations_route

Covered.GroupConversationsRoute = Covered.ConversationsRoute.extend({

  renderTemplate: function() {
    this.render('group_conversations', {into: 'organization', outlet: 'conversationsPane'});
    this.controllerFor('organization').set('focus', 'conversations');
    this.controllerFor('organization').set('composeTarget', 'group-conversations');
  }

});
