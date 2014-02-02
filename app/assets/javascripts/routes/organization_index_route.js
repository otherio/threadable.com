Threadable.OrganizationIndexRoute = Ember.Route.extend({
  redirect: function(organization){
    this.transitionTo('conversations', organization, 'my');
  }
});
