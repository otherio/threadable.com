Threadable.ConversationDetailsController = Ember.ObjectController.extend(Threadable.ConfirmationMixin, Threadable.RoutesMixin, {
  needs: ['organization', 'group'],
  organization: Ember.computed.alias('controllers.organization'),

  showGroupRecipients: false,

  actions: {
    toggleGroupRecipients: function() {
      this.toggleProperty('showGroupRecipients');
    },
  }

});
