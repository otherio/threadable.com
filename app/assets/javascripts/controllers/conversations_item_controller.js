Threadable.ConversationsItemController = Ember.ObjectController.extend(Threadable.RoutesMixin, {
  needs: ['group'],
  currentGroupSlug: Ember.computed.alias('controllers.group.model').readOnly(),

  groups: function() {
    return this.get('model.groups').rejectBy('slug', this.get('currentGroupSlug'));
  }.property('model.groups')
});
