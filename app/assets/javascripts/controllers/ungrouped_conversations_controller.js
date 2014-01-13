Covered.UngroupedConversationsController = Ember.ArrayController.extend({
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization.model')
});
