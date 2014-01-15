Covered.GroupRoute = Ember.Route.extend({

  model: function(params){
    return this.modelFor('groups').findBy('slug', params.group);
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').set('group', model);
    this.controllerFor('organization').set('composeTarget', 'group');
  }

});
