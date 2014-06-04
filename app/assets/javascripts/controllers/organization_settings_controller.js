Threadable.OrganizationSettingsController = Ember.ObjectController.extend(
  Threadable.CurrentUserMixin,
  Threadable.ConfirmationMixin,
  {
  needs: ['organization', 'application'],

  error: null,
  currentUser: Ember.computed.alias('controllers.application.currentUser'),
  updateInProgress: false,

  editableOrganization: function() { return this.get('model').copy(); }.property('model'),

  hasGoogleAuth: function() {
    var authorization = this.get('currentUser').authorizationFor('google_oauth2');
    if(!authorization) { return false; }
    return !! authorization.domain;
  }.property('currentUser'),

  currentUserIsGoogleUser: function() {
    return this.get('currentUser.slug') == this.get('googleUser.slug');
  }.property('currentUser', 'googleUser'),

  actions: {
    // updateOrganization: function() {
    //   this.set('error', null);
    //   this.set('updateInProgress', true);

    //   var organization = this.get('content');
    //   // organization.setProperties({
    //   //   description:       this.get('editableOrganization.description'),
    //   //   subjectTag:        this.get('editableOrganization.subjectTag'),
    //   //   color:             this.get('editableOrganization.color'),
    //   //   autoJoin:          this.get('editableOrganization.autoJoin'),
    //   //   holdMessages:      this.get('editableOrganization.holdMessages'),
    //   //   aliasEmailAddress: this.get('editableOrganization.aliasEmailAddress'),
    //   //   webhookUrl:        this.get('editableOrganization.webhookUrl'),
    //   //   googleSync:        this.get('editableOrganization.googleSync'),
    //   // });

    //   organization.saveRecord().then(organizationSaved.bind(this), error.bind(this));

    //   function organizationSaved(response) {
    //     organization.deserialize(response.organization);
    //     this.send('transitionToOrganization', organization);
    //     this.set('updateInProgress', false);
    //   }

    //   function error(response) {
    //     var error = response && response.error || 'an unknown error occurred';
    //     this.set('error', error);
    //     this.set('updateInProgress', false);
    //   }
    // },

    claimGoogleAccount: function() {
      $.ajax({
        type: "POST",
        url: "/api/organizations/" + this.get('slug') + "/claim_google_account"
      }).success(function(response) {
        this.get('model').deserialize(response.organization);
      }.bind(this)).error(function(response) {
        var error = response && JSON.parse(response.responseText).error || 'an unknown error occurred';
        this.set('error', error);
      }.bind(this));
    }

  }

});
