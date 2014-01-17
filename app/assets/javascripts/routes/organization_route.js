Covered.OrganizationRoute = Ember.Route.extend({

  model: function(params){
    this.controllerFor('organization').set('organization_slug', params.organization);
    return Covered.CurrentUser.fetch().then(function(currentUser) {
      var organization = currentUser.get('organizations').findBy('slug', params.organization);
      organization.loadMembers();
      return organization;
    });
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').set('organization', model);
  },

  renderTemplate: function() {
    this.render('organization', {into: 'application'});
    this.render('groups', {into: 'organization', outlet: 'groupsPane'});
  },

  actions: {
    goToCompose: function() {
      var composeTarget = this.controller.get('composeTarget');
      if (composeTarget === 'my-conversations')        return this.transitionTo('compose_my_conversation');
      if (composeTarget === 'my-tasks')                return this.transitionTo('compose_my_task');
      if (composeTarget === 'ungrouped-conversations') return this.transitionTo('compose_ungrouped_conversation');
      if (composeTarget === 'ungrouped-tasks')         return this.transitionTo('compose_ungrouped_task');
      if (composeTarget === 'group-conversations')     return this.transitionTo('compose_group_conversation');
      if (composeTarget === 'group-tasks')             return this.transitionTo('compose_group_task');
      throw new Error('unknonw composeTarget '+composeTarget);
    }
  }

});
