//= require ../tasks_route

Covered.MyTasksRoute = Covered.TasksRoute.extend({

  modelFetchOptions: function() {
    var organization = this.modelFor('organization');
    return {
      organization_id: organization.get('slug'),
      my: true
    };
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').set('group', null);
    this.controllerFor('organization').set('composeTarget', 'my-task');
  },

  renderTemplate: function() {
    this.render('my_conversations', {into: 'organization', outlet: 'conversationsPane'});
  }

});
