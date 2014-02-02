Threadable.OrganizationController = Ember.ObjectController.extend(Threadable.CurrentUserMixin, {
  needs: ['sidebar'],

  focus: 'conversations',
  organization_slug: null,

  heldMessagesUrl: function(){
    return '/' + this.get('slug') + '/held_messages';
  }.property('hasHeldMessages'),

  actions: {
    closeSidebar: function() {
      this.get('controllers.sidebar').send('closeSidebar');
    }
  }

});
