Covered.GroupMembersController = Ember.ArrayController.extend({
  needs: ['organization'],
  itemController: 'group_member',

  organization: Ember.computed.alias('controllers.organization').readOnly(),

  group: null,
  content: Ember.computed.alias('organization.members').readOnly()

});
