Threadable.OrganizationMembersController = Ember.ArrayController.extend(Threadable.CurrentUserMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  sortProperties: ['name'],

  currentMember: function() {
    return this.findBy('userId', this.get('currentUser.userId'));
  }.property('currentUser', 'content'),

  subscriberCount: function() {
    return this.get('content').filterBy('subscribed', true).length;
  }.property('content.@each.subscribed')
});
