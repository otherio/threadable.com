Threadable.GroupMemberController = Ember.ObjectController.extend(Threadable.ConfirmationMixin, {
  needs: ['group_members'],
  group: Ember.computed.alias('controllers.group_members.group').readOnly(),

  isMember: function() {
    return !!this.get('group.members').findBy('userId', this.get('userId'));
  }.property('group.members.@each'),


  actions: {
    addMember: function(organizationMember) {
      var group = this.get('group');
      organizationMember.addToGroup(group).then(function(groupMember) {
        group.get('members').addObject(groupMember);
      });
    },

    removeMember: function(organizationMember) {
      var
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
          organizationMember.removeFromGroup(group).then(function() {
            groupMembers.removeObject(groupMember);
          });
        }
      });
    },

    toggleInSummary: function() {
      if (this.get('saving')) return;
      this.toggleProperty('inSummary');
      this.save();
    },
  },

  save: function() {
    if (this.get('saving')) return;
    this.set('saving', true);
    this.get('model').saveRecord().then(function() {
      this.set('saving', false);
    }.bind(this));
  }

});
