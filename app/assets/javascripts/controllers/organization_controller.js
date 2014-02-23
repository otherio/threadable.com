Threadable.OrganizationController = Ember.ObjectController.extend(Threadable.CurrentUserMixin, {
  needs: ['sidebar'],

  focus: 'conversations',

  heldMessagesUrl: function(){
    return '/' + this.get('slug') + '/held_messages';
  }.property('model'),

  actions: {
    closeSidebar: function() {
      this.get('controllers.sidebar').send('closeSidebar');
    }
  }

});
