Covered.IndexRoute = Ember.Route.extend({

  renderTemplate: function() {
    // if we're signed in redirect to the first organization
    if (this.controllerFor('application').get('isSignedIn')){
      $.getJSON('/api/organizations').then(function(response){
        var organization = response.organizations[0];
        this.transitionTo('organization', organization.slug);
      }.bind(this));
    }else{
      this._super();
    }
  },

});
