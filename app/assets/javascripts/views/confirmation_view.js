Threadable.ConfirmationView = Ember.View.extend({
  templateName: 'confirmation',
  classNames: 'confirmation',
  message: null,
  approveText: 'yes',
  declineText: 'no',
  approvedCallback: Ember.K,
  declinedCallback: Ember.K,

  approve: function() {
    this.remove();
    this.approvedCallback();
  },

  decline: function() {
    this.remove();
    this.declinedCallback();
  },

  didInsertElement: function() {
    var
      view          = this,
      element       = this.$(),
      declineButton = this.$('.decline-button'),
      approveButton = this.$('.approve-button');

    element.on('focus', function() {
      console.debug('confirmation focused');
    });
    element.on('focus', function() {
      console.debug('confirmation focused');
    });

    $(document).on('keydown.confirmation', function(event) {
      if (event.which === 9){
        declineButton.focus();
        event.preventDefault();
      }
      if (event.which === 27){
        view.decline();
        event.preventDefault();
      }
    });

    declineButton.on('keydown.confirmation', function(event) {
      if (event.which !== 9) return;
      approveButton.focus();
      event.preventDefault();
      event.stopPropagation();
    });
    approveButton.on('keydown.confirmation', function(event) {
      if (event.which !== 9) return;
      declineButton.focus();
      event.preventDefault();
      event.stopPropagation();
    });

    declineButton.on('click.confirmation', function(event) {
      view.decline();
    });
    approveButton.on('click.confirmation', function(event) {
      view.approve();
    });

    declineButton.focus();
  },

  willDestroyElement: function() {
    $(document).off('keydown.confirmation');
    this.$('*').off();
  }

});
