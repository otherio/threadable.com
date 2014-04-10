Threadable.WelcomeModalView = Ember.View.extend({
  templateName: 'welcome_modal',
  classNames: 'welcome-modal',

  didInsertElement: function() {
  //   var
  //     view          = this,
  //     element       = this.$(),
  //     declineButton = this.$('.decline-button'),
  //     approveButton = this.$('.approve-button');

  //   $(document).on('keydown.confirmation', function(event) {
  //     if (event.which === 9){
  //       declineButton.focus();
  //       event.preventDefault();
  //     }
  //     if (event.which === 27){
  //       view.decline();
  //       event.preventDefault();
  //     }
  //   });

  //   declineButton.on('keydown.confirmation', function(event) {
  //     if (event.which !== 9) return;
  //     approveButton.focus();
  //     event.preventDefault();
  //     event.stopPropagation();
  //   });

  //   approveButton.on('keydown.confirmation', function(event) {
  //     if (event.which !== 9) return;
  //     declineButton.focus();
  //     event.preventDefault();
  //     event.stopPropagation();
  //   });

  //   declineButton.on('click.confirmation', function(event) {
  //     view.decline();
  //   });

  //   approveButton.on('click.confirmation', function(event) {
  //     view.approve();
  //   });

  //   declineButton.focus();
  },

  willDestroyElement: function() {
  //   $(document).off('keydown.confirmation');
  //   this.$('*').off();
  }

});
