Threadable.TasksItemController = Ember.ObjectController.extend(Threadable.RoutesMixin, {
  needs: ['tasks', 'group'],
  prioritizing: Ember.computed.alias('controllers.tasks.prioritizing').readOnly(),
  currentGroupSlug: Ember.computed.alias('controllers.group.model').readOnly(),
  draggable: function() { return String(this.get('prioritizing')); }.property('prioritizing'),

  groups: function() {
    return this.get('model.groups').rejectBy('slug', this.get('currentGroupSlug'));
  }.property('model.groups')
});
