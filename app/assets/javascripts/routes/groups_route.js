Covered.GroupsRoute = Ember.Route.extend({

  model: function(params){
    var organization_slug = this.controllerFor('organization').get('organization_slug');
    return Covered.Group.fetch({organization_id: organization_slug});
  },

  renderTemplate: function() {
    this.render('groups', {into: 'organization', outlet: 'groupsPane'});
    // this.render('groups', {into: 'organization', outlet: 'pane1'});
  },

});
