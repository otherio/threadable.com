Covered.OrganizationController = Ember.ObjectController.extend(Covered.CurrentUserMixin, {

  focus: null,
  previousFocus: null,
  organization_slug: null,

  heldMessagesUrl: function(){
    return '/' + this.get('slug') + '/held_messages'
  }.property('hasHeldMessages'),


  focusChanged: function(){
    this.set('previousFocus', this.get('focus'));
  },

  actions: {
    focusBack: function(){
      this.set('focus', this.get('previousFocus'));
    }
  }

});
