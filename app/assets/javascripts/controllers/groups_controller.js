Covered.GroupsController = Ember.ArrayController.extend(Covered.CurrentUserMixin, Covered.RoutesMixin, {
  needs: ['organization', 'application', 'conversation'],
  organization: Ember.computed.alias('controllers.organization'),
  currentPath: Ember.computed.alias('controllers.application.currentPath').readOnly(),
  currentConversation: Ember.computed.alias('controllers.conversation.model').readOnly(),

  closeGroupsSidebar: function() {
    this.set('organization.focus', 'conversations');
  },

  actions: {
    signOut: function() {
      this.signOut();
      this.transitionToRoute('index');
    },
    toggleSettings: function(){
      this.set('settingsVisible', !this.get('settingsVisible'));
    },
    toggleOrganization: function(){
      this.set('organizationVisible', !this.get('organizationVisible'));
    },
    closeGroupsSidebar: function() {
      this.closeGroupsSidebar();
    }
  }

});
