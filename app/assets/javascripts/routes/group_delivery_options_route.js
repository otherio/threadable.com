Threadable.GroupDeliveryOptionsRoute = Ember.Route.extend({
  model: function() {
    var groupSlug = this.modelFor('group');
    var group = this.modelFor('organization').get('groups').findBy('slug', groupSlug);

    return group.loadMembers(true).then(function(groupMembers) {
      var currentUser = this.controllerFor('organization').get('currentUser');
      var groupMember = groupMembers.findBy('id', currentUser.get('userId').toString());
      groupMember.set('organization', this.modelFor('organization'));
      return groupMember;
    }.bind(this));
  },

  afterModel: function(group, transition) {
    if (group) return;
    this.transitionTo('conversations', 'my');
  },

  setupController: function(controller, model) {
    var organization = this.controllerFor('organization');
    controller.set('group', organization.get('groups').findBy('slug', this.modelFor('group')));
    this._super(controller, model);
  },

  renderTemplate: function(controller, model) {
    this.render('group_delivery_options', {into: 'organization', outlet: 'pane1'});
    this.controllerFor('organization').set('focus', 'conversations');
  },

  actions: {
    transitionToGroup: function(group) {
      this.transitionTo('conversations', group.get('slug'));
    }
  }
});
