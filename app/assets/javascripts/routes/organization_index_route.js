/* /:organization */
Covered.OrganizationIndexRoute = Ember.Route.extend({
  // we never want to visit this route
  redirect: function(){
    this.transitionTo('group.index', 'all');
  }
});
