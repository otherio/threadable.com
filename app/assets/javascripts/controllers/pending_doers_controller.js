Threadable.PendingDoersController = Ember.ArrayController.extend({
  needs: ['doer_selector'],
  content: Ember.computed.alias('controllers.doer_selector'),
});
