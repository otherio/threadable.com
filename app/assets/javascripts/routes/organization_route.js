Covered.OrganizationRoute = Ember.Route.extend({

  model: function(params){
    return Covered.CurrentUser.fetch().then(function(currentUser) {
      var organization = currentUser.get('organizations').findBy('slug', params.organization);
      if (organization) organization.loadMembers();
      return organization;
    });
  },

  redirect: function(model, transition) {
    if (!model) this.transitionTo('/');
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('topbar').set('organization', model);
  },

  renderTemplate: function() {
    this.render('organization', {into: 'application'});
    var organization = this.controllerFor('organization');
    if(organization.get('hasHeldMessages')){
      $.UIkit.notify({
          message : '<i class="uk-icon-envelope-o"></i> You\'ve got <a href="/' + organization.get('slug') + '/held_messages">held messages</a>',
          status  : 'warning',
          timeout : 3000,
          pos     : 'top-right'
      });
    }
  }
});
