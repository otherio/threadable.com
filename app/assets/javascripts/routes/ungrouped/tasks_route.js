//= require ../tasks_route

Covered.UngroupedTasksRoute = Covered.TasksRoute.extend({

  modelFetchOptions: function() {
    var organization = this.modelFor('organization');
    return {
      organization_id: organization.get('slug'),
      ungrouped: true
    };
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').set('group', null);
    this.controllerFor('organization').set('composeTarget', 'ungrouped-tasks');
  },

  renderTemplate: function() {
    this.render('ungrouped_conversations', {into: 'organization', outlet: 'conversationsPane'});
  }

});
