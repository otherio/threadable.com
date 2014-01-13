Covered.GroupConversationsController = Covered.ConversationsController.extend({
  needs: ['group'],
  group: Ember.computed.alias('controllers.group').readOnly(),
});
