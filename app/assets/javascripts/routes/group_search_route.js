Threadable.GroupSearchRoute = Ember.Route.extend({

  renderTemplate: function() {
    this.render('group_search', {into: 'organization', outlet: 'pane1'});
  },

  setupController: function(controller, group, transition) {
    this._super.apply(this, arguments);
    var query;
    try{
      query = this.router.router.state.params.group_search_results.query;
    }catch(e){}
    controller.set('query', query);
  },

  actions: {
    search: function(query) {
      this.transitionTo('group_search_results', query);
    }
  }

});
