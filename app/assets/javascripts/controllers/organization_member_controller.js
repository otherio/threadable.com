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
    this.set('saving', true);
    setTimeout(function() { this.set('saving', false); }.bind(this), 1000);
  }
});
