Threadable.DoerSelectorController = Ember.ArrayController.extend({
  needs: ['organization', 'conversation'],
  model: Ember.computed.alias('controllers.organization.members'),

  itemController: 'doer_selector_item',

  doers: [],

  actions: {
    toggleDoerSelector: function() {
      this.get('controllers.conversation').send('toggleDoerSelector');
    }
  }
});
