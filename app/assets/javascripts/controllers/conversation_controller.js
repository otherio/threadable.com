Covered.ConversationController = Ember.ObjectController.extend({
  needs: ['organization'],
  groups: Ember.computed.alias('controllers.organization.groups'),

  conversationGroups: function() {
    return this.get('groups').filter(function(group) {
      return this.get('groupIds').indexOf(group.get('id')) > -1;
    }.bind(this));
  }.property('groupIds', 'groups')

});
