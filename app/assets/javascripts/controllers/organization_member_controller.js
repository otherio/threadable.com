Threadable.OrganizationMemberController = Ember.ObjectController.extend(Threadable.CurrentUserMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),

  actions: {
    toggleIsSubscribed: function() {
      this.toggleProperty('isSubscribed');
    }
  }
});
