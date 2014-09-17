Threadable.OrganizationRoute = Ember.Route.extend({

  model: function(params){
    return Threadable.Organization.fetch(params.organization).then(function(organization) {
      var currentUser = Threadable.currentUser;
      organization.loadMembers().then(function() {
        if (rails_env.docent_token){
          Threadable.setupDocent(currentUser, organization);
        }
      });
      Threadable.setupUserVoice(currentUser, organization);
      currentUser.set('currentOrganizationId', organization.get('id'));
      return organization;
    });
  },

  setupController: function(controller, organization) {
    this._super(controller, organization);
    this.controllerFor('topbar').set('organization', organization);
  },

  renderTemplate: function(controller, organization) {
    if (organization){
      this.render('organization', {into: 'application'});
      var organizationController = this.controllerFor('organization');
      if (organizationController.get('hasHeldMessages')) Threadable.notify('warning',
        '<i class="uk-icon-envelope-o"></i> You\'ve got <a href="/' +
        organizationController.get('slug') +
        '/held_messages">held messages</a>'
      );
    }else{
      this.render('not_found', {into: 'application'});
    }
  },

});
