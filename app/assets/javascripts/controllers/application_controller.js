Covered.ApplicationController = Ember.Controller.extend({
  queryParams: ['r'],
  r: null,

  transitions: [],

  currentUser: Ember.computed.alias('model'),

  isSignedIn: function() {
    return this.get('currentUser') && this.get('currentUser').get('userId');
  }.property('currentUser.userId'),

  goBack: function(){
    var transition = this.get('transitions')[1];
    if (transition) transition.retry();
  },

  router: function() {
    return this.container.lookup('router:main');
  }.property(),


  actions: {
    signOut: function(){
      Covered.signOut();
    }
  }

});
