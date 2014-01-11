Covered.ApplicationController = Ember.Controller.extend({

  transitions: [],

  currentUser: Ember.computed.alias('model'),

  isSignedIn: function() {
    return !!this.get('currentUser');
  }.property('currentUser'),

  // currentUserChanged: function(){
  //   console.log('CURRENT USER CHANGED');
  //   $.getJSON('/api/current_user/organizations').then(function(response){
  //     var organization = response.organizations[0];
  //     this.transitionTo('organization', organization.slug);
  //   }.bind(this));
  // }.observes('currentUser'),

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
