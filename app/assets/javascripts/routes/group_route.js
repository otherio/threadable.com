Covered.GroupRoute = Ember.Route.extend({

  model: function(params){
    return this.modelFor('organization').get('groups').findBy('slug', params.group);
  },

  renderTemplate: function() {
    this.render('conversations', {into: 'organization', outlet: 'conversationsPane'});
  }

});
