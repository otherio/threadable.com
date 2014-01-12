Covered.ConversationController = Ember.ObjectController.extend({
  needs: ['organization'],
  groups: Ember.computed.alias('controllers.organization.groups'),

  conversationGroups: function() {
    var groupIds = this.get('groupIds');
    if (!groupIds) return [];
    return this.get('groups').filter(function(group) {
      return groupIds.indexOf(group.get('id')) > -1;
    });
  }.property('groupIds', 'groups')

});
