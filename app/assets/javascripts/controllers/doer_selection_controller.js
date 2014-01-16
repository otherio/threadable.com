Covered.DoerSelectionController = Ember.ArrayController.extend({
  itemController: 'doer',
  doers: null

});

Covered.DoerController = Ember.ObjectController.extend({
  needs: ['doerSelection', 'conversation'],

  doers: Ember.computed.alias('controllers.doerSelection.doers'),

  isDoer: function() {
    var doerIds;
    var doers = this.get('doers');

    if(doers) {
      doerIds = doers.map(function(doer){
        return doer.get('id');
      });
    }

    return doerIds.indexOf(this.get('id')) > -1;
  }.property('doers.@each'),

  change: function() {
    var persidtedDoerIds;
    var persistedDoers = this.get('controllers.conversation.doers');

    if(persistedDoers) {
      persistedDoerIds = persistedDoers.map(function(doer){
        return doer.get('id');
      });
    }

    var doerHere = this.get('isDoer');
    var doerSaved = persistedDoerIds.indexOf(this.get('id')) > -1;

    if(doerHere == doerSaved) {
      return null;
    }

    if(doerSaved) {
      return 'removed';
    }

    return 'added';
  }.property('doers.@each', 'controllers.conversation.doers.@each'),

  isChanged: function() {
    return !!this.get('change');
  }.property('change'),

  isAdded: function() {
    return this.get('change') == 'added';
  }.property('change'),

  actions: {
    toggleDoer: function() {
      var doer  = this.get('content');
      var doers = this.get('doers');
      if(this.get('isDoer') ){
        this.get('controllers.doerSelection').set('doers', doers.reject(function(filteredDoer) {
          return doer.get('id') === filteredDoer.get('id');
        }));
      } else {
        doers.pushObject(doer);
      }

    }
  }
});
