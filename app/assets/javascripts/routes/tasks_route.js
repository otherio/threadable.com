//= require ./conversations_route

Covered.TasksRoute = Covered.ConversationsRoute.extend({

  doneTasksScope: 'done_tasks',
  notDoneTasksScope: 'not_done_tasks',

  groupSlug:    function() { return this.modelFor('group'); },
  organization: function() { return this.modelFor('organization'); },

  doneTasks: function() {
    return Covered.Conversation.fetchByGroupAndScope(this.organization(), this.groupSlug(), this.doneTasksScope);
  },

  notDoneTasks: function() {
    return Covered.Conversation.fetchByGroupAndScope(this.organization(), this.groupSlug(), this.notDoneTasksScope);
  },

  model: function(params) {
    return Ember.RSVP.Promise.all([this.doneTasks(), this.notDoneTasks()]).then(function(results) {
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
  },

  actions: {
    addConversation: function(conversation) {
      // this.controller.get('model').unshiftObject(conversation);
    },
    refresh: function(callback) {
      var notDoneTasks = this.controllerFor('notDoneTasks');

      this.notDoneTasks().then(function(newTasks) {
        notDoneTasks.set('model', newTasks);
      });
    }
  }

});
