Threadable.GroupSearchResultsController = Ember.ArrayController.extend(Threadable.RoutesMixin, {
  needs: ['organization', 'group'],
  organization:     Ember.computed.alias('controllers.organization').readOnly(),
  group:            Ember.computed.alias('controllers.group').readOnly(),
  organizationSlug: Ember.computed.alias('controllers.organization.slug').readOnly(),
  groupSlug:        Ember.computed.alias('controllers.group.model').readOnly(),

});
