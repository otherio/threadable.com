//= require ./conversations_controller

Covered.GroupConversationsController = Covered.ConversationsController.extend({
  needs: ['group'],
  group: Ember.computed.alias('controllers.group').readOnly(),

  conversationsFindOptions: function() {
    return {
      organization_id: this.get('organization.slug'),
      group_id: this.get('group.slug')
    };
  }

});
