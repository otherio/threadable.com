Threadable.OrganizationMemberController = Ember.ObjectController.extend(Threadable.CurrentUserMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),

  saving: false,
  roles: ['owner', 'member'],

  actions: {
    toggleSubscribed: function() {
      if (this.get('saving')) return;
      this.toggleProperty('subscribed');
      this.save();
    },

    setGetsNoUngroupedMail: function() {
      if (this.get('saving')) return;
      this.set('ungroupedMailDelivery', 'no_mail');
      this.save();
    },
    setGetsEachUngroupedMessage: function() {
      if (this.get('saving')) return;
      this.set('ungroupedMailDelivery', 'each_message');
      this.save();
    },
    setGetsUngroupedInSummary: function() {
      if (this.get('saving')) return;
      this.set('ungroupedMailDelivery', 'in_summary');
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
