Threadable.OrganizationMemberController = Ember.ObjectController.extend(Threadable.CurrentUserMixin, {
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
      this.toggleProperty('subscribed');
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
