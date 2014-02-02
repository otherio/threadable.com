Threadable.GroupController = Ember.ObjectController.extend({
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization')
});
