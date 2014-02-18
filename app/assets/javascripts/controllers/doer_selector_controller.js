Threadable.DoerSelectorController = Ember.ArrayController.extend({
  needs: ['organization', 'conversation'],
  content: Ember.computed.alias('controllers.organization.members'),

  itemController: 'doer_selector_item',
  sortProperties: ['isDoer'], // why doesnt this work!?!?! - Jared

  doers: function(){
    return this.get('controllers.conversation.doers').toArray();
  }.property('controlers.conversation', 'controlers.conversation.doers'),

  actions: {
    toggleDoerSelector: function() {
      this.get('controllers.conversation').send('toggleDoerSelector');
    }
  }
});
