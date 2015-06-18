Threadable.SidebarController = Ember.ArrayController.extend(Threadable.CurrentUserMixin, Threadable.RoutesMixin, Threadable.ConfirmationMixin, {
  needs: ['organization', 'application', 'conversation'],
  organization: Ember.computed.alias('controllers.organization'),
  currentPath: Ember.computed.alias('controllers.application.currentPath').readOnly(),
  currentConversation: Ember.computed.alias('controllers.conversation.model').readOnly(),

  open: function() {
    this.set('organization.focus', 'groups');
  },

  close: function() {
    this.set('organization.focus', 'conversations');
    this.set('settingsVisible', false);
    this.set('organizationVisible', false);
  },

  otherOrganizations: function(organization) {
    var organizations = Ember.ArrayProxy.create({content:[]});
    organizations.addObjects(this.get('currentUser.organizations'));
    organizations.removeObject(this.get('organization.model'));
    return organizations;
  }.property('organization.model','currentUser.organizations'),

  myGroups: function() {
    return this.get('organization.groups').filterBy('currentUserIsAMember', true).sort(this.primaryGroupFirst);
  }.property('organization.groups.@each.currentUserIsAMember'),

  otherGroups: function() {
    return this.get('organization.groups').filterBy('currentUserIsAMember', false).sort(this.primaryGroupFirst);
  }.property('organization.groups.@each.currentUserIsAMember'),

  actions: {
    toggleSettings: function(){
      this.toggleProperty('settingsVisible');
    },
    toggleOrganization: function(){
      this.toggleProperty('organizationVisible');
    },
    openSidebar: function() {
      this.open();
    },
    closeSidebar: function() {
      this.close();
    },
    joinGroup: function(group) {
      group.join().then(this.reopenGroups.bind(this, $('.sidebar .group.open')));
    },
    leaveGroup: function(group) {
      this.confirm({
        message: (
          "Are you sure you want to leave the "+
          group.get('name')+' group?'
        ),
        approveText: 'leave',
        declineText: 'cancel',
        approved: function(group) {
          group.leave().then(function(group) {
            this.reopenGroups($('.sidebar .group.open'));

            if(!this.get('organization.canReadPrivateGroups') && group.get('private') && !group.get('currentUserIsAMember')) {
              this.get('organization.groups').removeObject(group);
            }
          }.bind(this, group));
        }.bind(this, group)
      });
    }
  },

  // this is a lame hack - Jared
  reopenGroups: function(openGroups) {
    Ember.run.later(function() {
      openGroups.map(function() {
        var group = $('.sidebar .group[data-group-id='+$(this).data('groupId')+']');
        group.addClass('disable-all-transitions open');
        return group;
      });
    });
    Ember.run.later(function() {
      $('.disable-all-transitions').removeClass('disable-all-transitions');
    }, 200); // this should match the animation length
  },

  primaryGroupFirst: function(a,b) {
    if(b.get('primary')) {
      return 1;
    } else if (a.get('primary')) {
      return -1;
    }
    return b.get('name') < a.get('name') ? 1 : -1;
  }

});
