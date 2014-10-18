Threadable.DoerSelectorItemController = Ember.ObjectController.extend({
  needs: ['doerSelector', 'conversation'],

  doers: Ember.computed.alias('controllers.doerSelector.doers'),

  isDoer: function() {
    var doers = this.get('doers');
    if (doers.length < 1) return false;
    return !! doers.findBy('id', this.get('id'));
  }.property('doers.@each', 'id'),

  changeType: function() {
    var persistedDoerIds = [];
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
  }.property('id', 'isDoer', 'controllers.conversation.doers.@each'),

  isChanged: function() {
    return !!this.get('changeType');
  }.property('changeType'),

  isAdded: function() {
    return this.get('changeType') == 'added';
  }.property('changeType'),

  actions: {
    toggleDoer: function() {
      var doer  = this.get('model');
      var doers = this.get('doers');
      if(this.get('isDoer') ){
        this.get('controllers.doerSelector').set('doers', doers.rejectBy('id', doer.get('id')));
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
