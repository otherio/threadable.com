//= require ./conversations_controller

Covered.UngroupedConversationsController = Covered.ConversationsController.extend({

  conversationsFindOptions: function() {
    return {
      organization_id: this.get('organization.slug'),
      ungrouped: true
    };
  }

});
