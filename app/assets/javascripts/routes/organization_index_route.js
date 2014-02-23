Threadable.OrganizationIndexRoute = Ember.Route.extend({
  redirect: function(){
    var organization = this.modelFor('organization');
    this.transitionTo('conversations', organization, 'my');
  }
});
