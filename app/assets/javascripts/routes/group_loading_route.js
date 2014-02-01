Covered.GroupLoadingRoute = Ember.Route.extend({

  renderTemplate: function() {
    this.controllerFor('organization').set('focus', 'conversations');
    this.render('group/loading', {into: 'organization', outlet: 'pane1'});
  }

});
