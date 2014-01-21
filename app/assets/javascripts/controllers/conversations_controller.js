Covered.ConversationsController = Ember.ArrayController.extend(Covered.RoutesMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  itemController: 'conversations_item'
});
