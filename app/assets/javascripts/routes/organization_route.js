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
      if (composeTarget === 'my')        this.transitionTo('my_compose');
      if (composeTarget === 'ungrouped') this.transitionTo('ungrouped_compose');
      if (composeTarget === 'group')     this.transitionTo('group_compose');
    }
  }

});
