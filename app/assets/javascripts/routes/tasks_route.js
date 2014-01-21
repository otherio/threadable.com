Covered.TasksRoute = Covered.ConversationsRoute.extend({

  doneTasksScope: 'done_tasks',
  notDoneTasksScope: 'not_done_tasks',

  model: function(params) {
    var
      groupSlug = this.modelFor('group'),
      organization = this.modelFor('organization'),
      doneTasksPromise    = Covered.Conversation.fetchByGroupAndScope(organization, groupSlug, this.doneTasksScope),
      notDoneTasksPromise = Covered.Conversation.fetchByGroupAndScope(organization, groupSlug, this.notDoneTasksScope);

    return Ember.RSVP.Promise.all([doneTasksPromise, notDoneTasksPromise]).then(function(results) {
      return {doneTasks: results[0], notDoneTasks: results[1]};
    });
  },

  setupController: function(controller, context, transition) {
    this.controllerFor('navbar').set('showingConversationsListControls', false);
    this.controllerFor('doneTasks').set('model', context.doneTasks);
    this.controllerFor('notDoneTasks').set('model', context.notDoneTasks);
  },

  renderTemplate: function() {
    this.render('tasks', {into: 'organization', outlet: 'conversationsPane'});
    this.render('doneTasks', {into: 'tasks', outlet: 'doneTasks'});
    this.render('notDoneTasks', {into: 'tasks', outlet: 'notDoneTasks'});
  },

  actions: {
    addConversation: function(conversation) {
      // this.controller.get('model').unshiftObject(conversation);
    }
  }

});
