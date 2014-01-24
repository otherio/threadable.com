Covered.OrganizationController = Ember.ObjectController.extend(Covered.CurrentUserMixin, {
  needs: ['groups'],

  focus: null,
  organization_slug: null,

  heldMessagesUrl: function(){
    return '/' + this.get('slug') + '/held_messages';
  }.property('hasHeldMessages'),

  actions: {
    closeGroupsSidebar: function() {
      this.get('controllers.groups').send('closeGroupsSidebar');
    }
  }

});
