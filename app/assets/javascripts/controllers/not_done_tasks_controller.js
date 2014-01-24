Covered.NotDoneTasksController = Ember.ArrayController.extend(Covered.RoutesMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  itemController: 'not_done_tasks_item',

  content: [],
  sortProperties: ['position'],
  sortAscending: true
});
