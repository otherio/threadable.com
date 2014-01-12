Covered.GroupRoute = Ember.Route.extend({

  model: function(params){
    return this.modelFor('organization').get('groups').findBy('slug', params.group);
  },

  renderTemplate: function() {
    // this.render('group', {into: 'organization', outlet: 'conversationsPane'});
    this.render('conversations.index', {into: 'organization', outlet: 'conversationsPane'});
  }

});
