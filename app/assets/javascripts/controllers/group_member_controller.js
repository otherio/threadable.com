Threadable.GroupMemberController = Ember.ObjectController.extend(Threadable.ConfirmationMixin, {
  needs: ['group_members'],
  group: Ember.computed.alias('controllers.group_members.group').readOnly(),

  updateInProgress: false,

  isMember: function() {
    return !!this.get('group.members').findBy('userId', this.get('userId'));
  }.property('group.members.@each'),

  actions: {
    addMember: function(organizationMember) {
      var
        controller = this,
        group      = this.get('group');

      this.set('updateInProgress', true);

      organizationMember.addToGroup(group).then(function(groupMember) {
        groupMember.set('group', group);
        groupMember.set('organization', group.get('organization'));
        group.get('members').addObject(groupMember);
        controller.transitionToRoute('group_member', groupMember);
        this.set('updateInProgress', false);
      }.bind(this));
    },

    removeMember: function(organizationMember) {
      var
        controller   = this,
        group        = this.get('group'),
        groupMembers = group.get('members'),
        groupMember  = groupMembers.findBy('userId', organizationMember.get('userId'));

      this.confirm({
        message: (
          "Are you sure you want to remove "+
          groupMember.get('name')+' from the '+
          this.get('group.name')+' group?'
        ),
        approveText: 'remove',
        declineText: 'cancel',
        approved: function() {
          this.set('updateInProgress', true);

          organizationMember.removeFromGroup(group).then(function() {
            groupMembers.removeObject(groupMember);
            controller.transitionToRoute('group_members');
            this.set('updateInProgress', false);
          }.bind(this));
        }.bind(this)
      });
    },

    toggleGetsInSummary: function() {
      if (this.get('saving')) return;
      this.toggleProperty('getsInSummary');
      this.save();
    },
  },

  save: function() {
    var controller = this;
    if (controller.get('saving')) return;
    controller.set('saving', true);
    controller.get('model').saveRecord().then(
      function() {
        controller.set('saving', false);
      },
      function() {
        controller.set('saving', false);
      }
    );
  }

});
