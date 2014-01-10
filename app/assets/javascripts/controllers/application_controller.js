Covered.ApplicationController = Ember.Controller.extend({

  init: function() {
    if (Covered.currentUserId){
      var user = this.store.find('user', Covered.currentUserId,
        function() {
          debugger
        },
        function() {
          debugger
        }
      );

      this.set('currentUser', user);
      this.set('isSignedIn', true);
      delete Covered.currentUserId;
    }
  },

  transitions: [],

  isSignedIn: false,
  currentUser: null,

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
