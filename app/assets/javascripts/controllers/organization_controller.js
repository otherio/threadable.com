Covered.OrganizationController = Ember.ObjectController.extend(Covered.CurrentUserMixin, {

  focus: null,
  previousFocus: null,
  organization_slug: null,
  composeTarget: null, // my || ungrouped || group


  focusChanged: function(){
    this.set('previousFocus', this.get('focus'));
  },

  actions: {
    focusBack: function(){
      this.set('focus', this.get('previousFocus'));
    }
  }

});
