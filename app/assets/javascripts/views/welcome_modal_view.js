Threadable.WelcomeModalView = Ember.View.extend({
  templateName: 'welcome_modal',
  classNames: 'welcome-modal',

  didInsertElement: function() {
    var root = this.$(), controller = this.get('controller');
    root.on('click', function(event) {
      if (event.target === root[0]) controller.send('dismissWelcomeModalView');
    });
  },

});
