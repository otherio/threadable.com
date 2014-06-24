Threadable.TasksItemController = Threadable.ConversationsItemController.extend(Threadable.RoutesMixin, {
  needs: ['tasks', 'group'],
  prioritizing: Ember.computed.alias('controllers.tasks.prioritizing').readOnly(),
  draggable: function() { return String(this.get('prioritizing')); }.property('prioritizing')
});
