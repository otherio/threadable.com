Threadable.OrganizationMembersController = Ember.ArrayController.extend(Threadable.CurrentUserMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
});
