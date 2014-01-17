//= require ./conversation_route

Covered.ComposeGroupConversationRoute = Covered.ComposeConversationRoute.extend({

  groups: function(){
    return [this.modelFor('group')];
  }

});
