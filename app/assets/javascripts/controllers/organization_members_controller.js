Threadable.OrganizationMembersController = Ember.ArrayController.extend(Threadable.CurrentUserMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  sortProperties: ['name'],

  currentMember: function() {
    return this.findBy('userId', this.get('currentUser.userId'));
  }.property('currentUser', 'model'),

  subscriberCount: function() {
    return this.get('model').filterBy('subscribed', true).length;
  }.property('model.@each.subscribed')
});
