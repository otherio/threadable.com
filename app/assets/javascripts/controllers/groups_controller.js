Covered.GroupsController = Ember.ArrayController.extend(Covered.CurrentUserMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization'),

  actions: {
    signOut: function() {
      this.signOut();
      this.transitionToRoute('index');
    },
    toggleSettings: function(){
      this.set('settingsVisible', !this.get('settingsVisible'));
    }
  }

});
