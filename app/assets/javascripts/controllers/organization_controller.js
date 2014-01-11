Covered.OrganizationController = Ember.ObjectController.extend(Covered.AuthenticationMixin, {

  focus: null,
  previousFocus: null,
  organization_slug: null,
  // group: null,
  // conversation: null,
  // group: Ember.computed.alias('controllers.organization.group'),
  // conversation: Ember.computed.alias('controllers.organization.group_conversation'),


  focusChanged: function(){
    this.set('previousFocus', this.get('focus'));
  },

  actions: {
    focusBack: function(){
      this.set('focus', this.get('previousFocus'));
    }
  }

});
