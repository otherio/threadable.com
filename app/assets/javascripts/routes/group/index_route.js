/* /:organization/groups/:group */
Covered.GroupIndexRoute = Ember.Route.extend({
  renderTemplate: function(){
    this.controllerFor('organization').set('focus', 'conversations');
  }
});
