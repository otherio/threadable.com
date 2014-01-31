Covered.GroupsController = Ember.ArrayController.extend(Covered.CurrentUserMixin, Covered.RoutesMixin, {
  needs: ['organization', 'application', 'conversation'],
  organization: Ember.computed.alias('controllers.organization'),
  currentPath: Ember.computed.alias('controllers.application.currentPath').readOnly(),
  currentConversation: Ember.computed.alias('controllers.conversation.model').readOnly(),

  openGroupsSidebar: function() {
    this.set('organization.focus', 'groups');

    var closeGroupsSidebar = this.closeGroupsSidebar.bind(this);
    // there was code here to make the sidebar not suck when you hit tab. however, it broke everything else.
    // we should fix that, though.
  },

  closeGroupsSidebar: function() {
    $(document).off('focus.closeGroupsSidebar keydown.closeGroupsSidebar');
    this.set('organization.focus', 'conversations');
    this.set('settingsVisible', false);
    this.set('organizationVisible', false);
    UserVoice.hide();
  },


  otherOrganizations: function(organization) {
    var organizations = Ember.ArrayProxy.create({content:[]});
    organizations.addObjects(this.get('currentUser.organizations'));
    organizations.removeObject(this.get('organization.model'));
    return organizations;
  }.property('organization.model','currentUser.organizations'),

  otherGroups: function() {
    return this.get('organization.groups').filterBy('currentUserIsAMember', false);
  }.property('organization.groups'),

  myGroups: function() {
    return this.get('organization.groups').filterBy('currentUserIsAMember', true);
  }.property('organization.groups'),

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
