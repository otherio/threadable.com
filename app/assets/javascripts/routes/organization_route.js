Threadable.OrganizationRoute = Ember.Route.extend({

  model: function(params){
    return Threadable.CurrentUser.fetch().then(function(currentUser) {
      var organization = currentUser.get('organizations').findBy('slug', params.organization);
      if (organization){
        organization.loadMembers();
        Threadable.setupUserVoice(currentUser, organization);
      }
      return organization;
    })
  },

  setupController: function(controller, organization) {
    this._super(controller, organization);
    this.controllerFor('topbar').set('organization', organization);
  },

  renderTemplate: function(controller, organization) {
    if (organization){
      this.render('organization', {into: 'application'});
      var organization = this.controllerFor('organization');
      if (organization.get('hasHeldMessages')) Threadable.notify('warning',
        '<i class="uk-icon-envelope-o"></i> You\'ve got <a href="/' +
        organization.get('slug') +
        '/held_messages">held messages</a>'
      )
    }else{
      this.render('not_found', {into: 'application'});
    }
  },

});
