// This is a base class. We should never actually endup here
Covered.ConversationsController = Ember.ArrayController.extend({
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
});
