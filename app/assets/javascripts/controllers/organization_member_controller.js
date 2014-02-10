Threadable.OrganizationMemberController = Ember.ObjectController.extend(Threadable.CurrentUserMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),

  saving: false,

  actions: {
    toggleIsSubscribed: function() {
      if (this.get('saving')) return;
      this.toggleProperty('isSubscribed');
      this.save();
    }
  },

  save: function() {
    if (this.get('saving')) return;
    this.set('saving', true);
    this.get('model').saveRecord().then(function() {
      this.set('saving', false);
    }.bind(this));
  }
});
