Threadable.GroupMembersController = Ember.ArrayController.extend({
  needs: ['organization'],
  itemController: 'group_member',
  sortProperties: ['name'],

  organization: Ember.computed.alias('controllers.organization').readOnly(),

  group: null,
  model: Ember.computed.alias('organization.members').readOnly(),

  summaryCount: function() {
    return this.get('group.members').filterBy('getsInSummary', true).length;
  }.property('group.members.@each.getsInSummary')

});
