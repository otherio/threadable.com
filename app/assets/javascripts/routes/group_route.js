Covered.GroupRoute = Ember.Route.extend({

  model: function(params){
    if (params.group === 'all'){
      return null;
    }
    return this.modelFor('groups').findBy('slug', params.group);
  },

  renderTemplate: function() {
    this.render('group', {into: 'organization', outlet: 'conversationsPane'});
  }

});
