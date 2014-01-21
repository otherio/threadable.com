Covered.NotDoneTasksController = Ember.ArrayController.extend(Covered.RoutesMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  itemController: 'tasks_item',
});
