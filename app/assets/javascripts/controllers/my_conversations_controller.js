//= require ./conversations_controller

Covered.MyConversationsController = Covered.ConversationsController.extend({

  conversationsFindOptions: function() {
    return {
      organization_id: this.get('organization.slug'),
      my: true
    };
  }

});
