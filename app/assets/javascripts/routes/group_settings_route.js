Threadable.GroupSettingsRoute = Ember.Route.extend({
  model: function(group) {
    var groupSlug = this.modelFor('group');
    return this.modelFor('organization').get('groups').findBy('slug', groupSlug);
  },

  renderTemplate: function(controller, model) {
    this.render('group_settings', {into: 'organization', outlet: 'pane1'});
    this.controllerFor('organization').set('focus', 'conversations');
    controller.set('editAdvanced', !!model.get('aliasEmailAddress') || !!model.get('webhookUrl'));
  },

  actions: {
    transitionToGroup: function(group) {
      this.transitionTo('conversations', group.get('slug'));
    }
  }
});
