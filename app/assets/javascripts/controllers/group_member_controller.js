Threadable.GroupMemberController = Ember.ObjectController.extend(Threadable.ConfirmationMixin, {
  needs: ['group_members', 'organization'],
  group: Ember.computed.alias('controllers.group_members.group'),
  organization: Ember.computed.alias('controllers.organization'),

  updateInProgress: false,

  deliveryMethods: [
    {prettyName: 'Send each message',                  method: 'gets_each_message'},
    {prettyName: 'Daily summary',                      method: 'gets_in_summary'},
    {prettyName: 'First message of each conversation', method: 'gets_first_message'}
  ],

  isMember: function() {
    return !!this.get('group.members').findBy('userId', this.get('userId'));
  }.property('group.members.@each'),

  notEditable: function() {
    return !this.get('canChangeDelivery');
  }.property('canChangeDelivery'),

  autoSave: function() {
    if (this.get('saving')) return;
    this.save();
  }.observes('deliveryMethod'),

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
        if(parseInt(groupMember.get('id')) == this.get('organization.currentUser.userId')) {
          group.set('currentUserIsAMember', true);
        }
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
            if(parseInt(groupMember.get('id')) == this.get('organization.currentUser.userId')) {
              group.set('currentUserIsAMember', false);
            }
            controller.transitionToRoute('group_members');
            this.set('updateInProgress', false);
          }.bind(this));
        }.bind(this)
      });
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
