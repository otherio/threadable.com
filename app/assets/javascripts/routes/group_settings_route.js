Covered.GroupSettingsRoute = Ember.Route.extend({
  model: function(group) {
    var emailAddressTag = this.modelFor('group');
    return this.modelFor('organization').get('groups').findBy('emailAddressTag', emailAddressTag);
  },

  renderTemplate: function() {
    this.render('group_settings', {into: 'organization', outlet: 'pane1'});
    this.controllerFor('organization').set('focus', 'conversations');
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    if (model) controller.set('editableGroup', model.copy());
  },

  actions: {
    transitionToGroup: function(group) {
      this.transitionTo('conversations', group.get('slug'));
    }
  }
});
