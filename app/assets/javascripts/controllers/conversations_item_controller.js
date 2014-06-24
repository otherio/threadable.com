Threadable.ConversationsItemController = Ember.ObjectController.extend(Threadable.RoutesMixin, {
  needs: ['group'],
  currentGroupSlug: Ember.computed.alias('controllers.group.model').readOnly(),

  groups: function() {
    var displayGroups = this.get('model.groups').rejectBy('slug', this.get('currentGroupSlug'));
    if(displayGroups.length > 1) {
      return displayGroups;
    }

    // only show the primary group when there's more than one group
    return displayGroups.rejectBy('primary');
  }.property('model.groups')
});
