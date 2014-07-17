Threadable.OrganizationSettingsController = Ember.ObjectController.extend(
  Threadable.CurrentUserMixin,
  Threadable.ConfirmationMixin,
  {
  needs: ['organization', 'application'],

  error: null,
  currentUser: Ember.computed.alias('controllers.application.currentUser'),
  domainSortProperties: ['domain:asc'],
  sortedDomains: Ember.computed.sort('emailDomains', 'domainSortProperties'),
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

  internalDomainOutgoing: function() {
    return ! this.get('emailDomains').find(function(domain) { return domain.get('outgoing'); });
  }.property('emailDomains'),

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
    },

    addDomain: function() {
      var organization = this.get('content');

      var domain = Threadable.EmailDomain.create({
        domain: this.get('domain'),
        organization: organization
      });

      domain.saveRecord().then(
        domainSaved.bind(this),
        error.bind(this)
      );

      function domainSaved(response) {
        domain.deserialize(response.domain);
        this.get('controllers.organization.emailDomains').pushObject(domain);
        this.set('domain', null);
      }

      function error(response) {
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
      }
    },

    outgoingDomain: function(domain) {
      var organization = this.get('content');

      if(domain == 'none') {
        domain = organization.get('emailDomains').find(function(domain) { return domain.get('outgoing'); });
        domain.set('outgoing', false);
      } else {
        domain.set('outgoing', true);
      }

      domain.saveRecord().then(
        this.get('content').loadEmailDomains(true)
      );
    },

    deleteDomain: function(domain) {
      domain.deleteRecord().then(
        this.get('content').loadEmailDomains(true)
      );
    },


  }

});
