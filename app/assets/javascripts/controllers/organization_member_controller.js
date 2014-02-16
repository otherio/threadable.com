Threadable.OrganizationMemberController = Ember.ObjectController.extend(Threadable.CurrentUserMixin, Threadable.ConfirmationMixin, {
  needs: ['organization', 'organization_members'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  currentMember: Ember.computed.alias('controllers.organization_members.currentMember').readOnly(),

  saving: false,
  roles: ['owner', 'member'],

  canChangeRole: function() {
    return this.get('currentMember.isOwner') && this.get('currentMember.userId') !== this.get('userId');
  }.property('userId', 'currentMember.userId', 'currentMember.isOwner'),

  memberChanged: function() {
    console.debug('Member changed', this.get('model').serialize());
    this.save();
  }.observes('role', 'subscribed', 'ungroupedMailDelivery'),

  actions: {
    toggleSubscribed: function() {
      if (this.get('saving')) return;

      if (!this.get('subscribed')){
        this.set('subscribed', true);
        return
      }

      this.confirm({
        message: (
          "Are you sure you want to unsubscribe " + this.get('name') +
          ' from the ' + this.get('organization.name') + ' organization?'
        ),
        approveText: 'Unsubscribe',
        declineText: 'cancel',
        approved: function() {
          this.set('subscribed', false);
        }.bind(this)
      });


    },
    setGetsNoUngroupedMail: function() {
      if (this.get('saving')) return;
      this.set('ungroupedMailDelivery', 'no_mail');
    },
    setGetsEachUngroupedMessage: function() {
      if (this.get('saving')) return;
      this.set('ungroupedMailDelivery', 'each_message');
    },
    setGetsUngroupedInSummary: function() {
      if (this.get('saving')) return;
      this.set('ungroupedMailDelivery', 'in_summary');
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
