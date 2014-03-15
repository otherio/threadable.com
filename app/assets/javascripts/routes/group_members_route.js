Threadable.GroupMembersRoute = Ember.Route.extend({

  model: function(params){
    var
      organization = this.modelFor('organization'),
      groupSlug    = this.modelFor('group'),
      group        = organization.get('groups').findBy('slug', groupSlug);
    if (!group) return;
    group.set('organization', organization);

    return group.loadMembers(true).then(function(groupMembers) {
      return group;
    });
  },

  afterModel: function(group, transition) {
    if (group) return
    this.transitionTo('conversations','my');
  },

  setupController: function(controller, group, transition) {
    controller.set('group', group);
  },

  renderTemplate: function() {
    this.render('group_members', {into: 'organization', outlet: 'pane1'});
  },

});
