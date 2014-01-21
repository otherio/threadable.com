Covered.ConversationsController = Ember.ArrayController.extend(Covered.RoutesMixin, {
  needs: ['organization', 'navbar'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  itemController: 'conversations_item',
  showingConversationsListControls: Ember.computed.alias('controllers.navbar.showingConversationsListControls'),
});
