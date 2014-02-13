Threadable.OrganizationMembersController = Ember.ArrayController.extend(Threadable.CurrentUserMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),

  currentMember: function() {
    return this.findBy('userId', this.get('currentUser.userId'));
  }.property('currentUser', 'content')
});
