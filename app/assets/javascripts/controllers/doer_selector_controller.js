Threadable.DoerSelectorController = Ember.ArrayController.extend({
  needs: ['conversation'],

  itemController: 'doer_selector_item',
  sortProperties: ['isDoer'], // why doesnt this work!?!?! - Jared

  doers: null,

  actions: {
    toggleDoerSelector: function() {
      this.get('controllers.conversation').send('toggleDoerSelector');
    }
  }
});
