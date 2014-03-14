Threadable.GroupSearchTextFieldComponent = Ember.TextField.extend({
  action: 'search',
  classNames: ['group-search-test-field'],


  keyUp: function(event) {
    this.triggerAction({action: 'search', actionContext: this.get('value')});
  },

});
