Covered.ApplicationController = Ember.Controller.extend({

  transitions: [],

  currentUser: Ember.computed.alias('model'),

  isSignedIn: function() {
    return this.get('currentUser') && this.get('currentUser').get('userId');
  }.property('currentUser.userId'),

  goBack: function(){
    var transition = this.get('transitions')[1];
    if (transition) transition.retry();
  },

  actions: {
    signOut: function(){
      Covered.signOut();
    }
  }

});
