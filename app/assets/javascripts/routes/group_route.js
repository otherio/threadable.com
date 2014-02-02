Threadable.GroupRoute = Ember.Route.extend({

  model: function(params){
    return params.group;
  },

  setupController: function(controller, context, tranisition) {
    this._super(controller, context, tranisition);
    var group = this.modelFor('organization').get('groups').findBy('slug', context);
    this.controllerFor('topbar').set('group', group);
  }

});
