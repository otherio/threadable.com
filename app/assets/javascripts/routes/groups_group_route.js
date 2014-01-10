Covered.GroupsGroupRoute = Ember.Route.extend({
  renderTemplate: function() {
    this.controllerFor('organization').set('focus','conversation');
    // Note: this route does not render any template
  }
});
