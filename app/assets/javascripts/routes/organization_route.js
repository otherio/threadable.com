Covered.OrganizationRoute = Ember.Route.extend({
  beforeModel: function(transition) {
    if (!Covered.isSignedIn()) {
      var signInController = this.controllerFor('sign_in');
      signInController.set('previousTransition', transition);
      this.transitionTo('sign_in');
    }
  },

  model: function(params){
    return Covered.CurrentUser.fetch().then(function(currentUser) {
      var organization = currentUser.get('organizations').findBy('slug', params.organization);
      organization.loadMembers();
      return organization;
    });
  },

  redirect: function(model, transition) {
    if (!model) this.transitionTo('sign_out');
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').set('organization', model);
  },

  renderTemplate: function() {
    this.render('organization', {into: 'application'});
    this.render('groups', {into: 'organization', outlet: 'groupsPane'});
  }

});
