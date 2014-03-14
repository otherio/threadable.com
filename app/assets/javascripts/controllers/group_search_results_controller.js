Threadable.GroupSearchResultsController = Ember.ArrayController.extend(Threadable.RoutesMixin, {
  needs: ['organization', 'group'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  group: Ember.computed.alias('controllers.group').readOnly(),

  organizationSlug: function(){ return this.get('organization.slug'); }.property('organization'),
  groupSlug: function(){ return this.get('group.model'); }.property('group'),

});
