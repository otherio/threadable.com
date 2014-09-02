Threadable.ConversationsItemController = Ember.ObjectController.extend(Threadable.RoutesMixin, {
  needs: ['group'],
  currentGroupSlug: Ember.computed.alias('controllers.group.model').readOnly(),

  groups: function() {
    var currentGroupSlug = this.get('currentGroupSlug');
    var displayGroups = this.get('model.groups').rejectBy('slug', currentGroupSlug);

    return displayGroups;
  }.property('model.groups')
});
