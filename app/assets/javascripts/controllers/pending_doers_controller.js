Threadable.PendingDoersController = Ember.ArrayController.extend({
  needs: ['doer_selector'],
  model: Ember.computed.alias('controllers.doer_selector'),
});
