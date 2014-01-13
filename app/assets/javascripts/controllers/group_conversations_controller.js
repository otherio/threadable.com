Covered.GroupConversationsController = Ember.ArrayController.extend({
  needs: ['organization', 'group'],
  organization: Ember.computed.alias('controllers.organization.model'),
  group: Ember.computed.alias('controllers.group.model'),
});
