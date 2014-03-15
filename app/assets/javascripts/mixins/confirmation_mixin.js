Threadable.ConfirmationMixin = Ember.Mixin.create({
  needs: "application",

  confirm: function(options) {
    Threadable.ConfirmationView.create({
      container: this.container,
      message:     options.message,
      description: options.description,
      approveText: options.approveText,
      declineText: options.declineText,
      approvedCallback: options.approved || Ember.K,
      declinedCallback: options.declined || Ember.K,
    }).appendTo('body');
  }
});
