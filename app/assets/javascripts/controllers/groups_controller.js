Covered.GroupsController = Ember.ArrayController.extend(Covered.CurrentUserMixin, Covered.RoutesMixin, {
  needs: ['organization', 'application', 'conversation'],
  organization: Ember.computed.alias('controllers.organization'),
  currentPath: Ember.computed.alias('controllers.application.currentPath').readOnly(),
  currentConversation: Ember.computed.alias('controllers.conversation.model').readOnly(),

  openGroupsSidebar: function() {
    this.set('organization.focus', 'groups');

    var closeGroupsSidebar = this.closeGroupsSidebar.bind(this);

    $('.groups-pane a:first').focus();

    $(document).on('focus.closeGroupsSidebar keydown.closeGroupsSidebar', '*', function(event) {
      if ($(event.target).parents('.groups-pane').length !== 0) return;
      event.preventDefault();
      setTimeout(function() { $('.groups-pane a:first').focus(); });
      return false;
    });
    $(document).on('keydown.closeGroupsSidebar', '*', function(event) {
      if (event.which !== 27) return;
      event.preventDefault();
      closeGroupsSidebar();
      return false;
    });
  },

  closeGroupsSidebar: function() {
    $(document).off('focus.closeGroupsSidebar keydown.closeGroupsSidebar');
    this.set('organization.focus', 'conversations');
    this.set('settingsVisible', false);
    this.set('organizationVisible', false);
    UserVoice.hide();
  },

  actions: {
    signOut: function() {
      this.signOut();
      this.transitionToRoute('index');
    },
    toggleSettings: function(){
      this.toggleProperty('settingsVisible');
    },
    toggleOrganization: function(){
      this.toggleProperty('organizationVisible');
    },
    openGroupsSidebar: function() {
      this.openGroupsSidebar();
    },
    closeGroupsSidebar: function() {
      this.closeGroupsSidebar();
    }
  }

});
