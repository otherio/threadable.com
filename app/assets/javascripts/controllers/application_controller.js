Threadable.ApplicationController = Ember.Controller.extend({

  transitions: [],

  currentUser: Ember.computed.alias('model'),

  goBack: function(){
    var transition = this.get('transitions')[1];
    if (transition) transition.retry();
  },

  router: function() {
    return this.container.lookup('router:main');
  }.property(),


  actions: {
    signOut: function(){
      Threadable.signOut();
    }
  }

});
