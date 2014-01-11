Covered.ApplicationController = Ember.Controller.extend({

  transitions: [],

  currentUser: Ember.computed.alias('model'),

  isSignedIn: function() {
    return this.get('currentUser') && this.get('currentUser').get('userId');
  }.property('currentUser.userId'),

  isSignedInChanged: function(){
    console.log('isSignedIn CHANGED to', this.get('isSignedIn'));
    if (this.get('isSignedIn')){
      Covered.Organization.fetch().then(redirectToFirstOrganization.bind(this));
    }

    function redirectToFirstOrganization(organizations){
      var organization = organizations.objectAt(0);
      if (organization) this.transitionTo('organization', organization.get('slug'));
    }

  }.observes('isSignedIn'),

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
