Covered.GroupsRoute = Ember.Route.extend({

  model: function(params){
    return this.modelFor('organization').get('groups');
  }

});
