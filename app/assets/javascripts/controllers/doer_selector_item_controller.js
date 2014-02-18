Threadable.DoerSelectorItemController = Ember.ObjectController.extend({
  needs: ['doerSelector', 'conversation'],

  doers: Ember.computed.alias('controllers.doerSelector.doers'),

  isDoer: function() {
    var doers = this.get('doers');
    if (!doers) return false;
    return doers.mapBy('id').indexOf(this.get('id')) !== -1;
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
    var doerSaved = persistedDoerIds.indexOf(this.get('id')) !== -1;

    if (doerHere == doerSaved) return null;
    if (doerSaved) return 'removed';
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
        this.get('controllers.doerSelector').set('doers', doers.reject(function(filteredDoer) {
          return doer.get('id') === filteredDoer.get('id');
        }));
      } else {
        doers.pushObject(doer);
      }
      this.get('controllers.conversation').send('toggleDoerSelector');
      Ember.run(function() {
        var container = $('.conversation-show:first');
        var reply = container.find('.reply');
        var newScrollTop = container.scrollTop() + reply.position().top;
        $(".conversation-show").animate({scrollTop: newScrollTop}, 250);
      });
    }
  }
});
