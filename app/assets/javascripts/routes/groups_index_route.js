/* /:organization/groups */
Covered.GroupsIndexRoute = Ember.Route.extend({
  renderTemplate: function(){
    this.controllerFor('organization').set('focus', 'groups');
  }
});
