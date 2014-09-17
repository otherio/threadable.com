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

  signupMethods: [
    {prettyName: 'By invitation only',          method: false},
    {prettyName: 'Anyone can join via the web', method: true}
  ],

  membershipTypes: [
    {prettyName: 'Members and owners', role: 'member'},
    {prettyName: 'Owners only',        role: 'owner' }
  ],

  isFree: function() {
    return ! this.get('isPaid');
  }.property('isPaid'),

  editableOrganization: function() { return this.get('model').copy(); }.property('model'),

  descriptionLengthRemaining: function() {
    var description = this.get('editableOrganization.description');
    if(description) {
      return 250 - this.get('editableOrganization.description').replace(/\n/g, "\r\n").length;
    } else {
      return 250;
    }
  }.property('editableOrganization.description'),

  joinLink: function() {
    return "/" + this.get('slug') + '?view=true';
  }.property('slug'),

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
    updateOrganization: function() {
      this.set('error', null);
      this.set('updateInProgress', true);

      var organization = this.get('model');
      organization.setProperties({
        name:         this.get('editableOrganization.name'),
        description:  this.get('editableOrganization.description'),
        publicSignup: this.get('editableOrganization.publicSignup'),

        groupMembershipPermission: this.get('editableOrganization.groupMembershipPermission'),
        groupSettingsPermission:   this.get('editableOrganization.groupSettingsPermission'),
      });

      organization.saveRecord().then(organizationSaved.bind(this), error.bind(this));

      function organizationSaved(response) {
        organization.deserialize(response.organization);
        this.set('updateInProgress', false);
      }

      function error(response) {
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
        this.set('updateInProgress', false);
      }
    },

    claimGoogleAccount: function() {
      this.set('error', null);
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
      this.set('error', null);
      var organization = this.get('model');

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
      this.set('error', null);
      var organization = this.get('model');

      if(domain == 'none') {
        domain = organization.get('emailDomains').find(function(domain) { return domain.get('outgoing'); });
        domain.set('outgoing', false);
      } else {
        domain.set('outgoing', true);
      }

      domain.saveRecord().then(
        this.get('model').loadEmailDomains(true)
      );
    },

    deleteDomain: function(domain) {
      this.set('error', null);
      domain.deleteRecord().then(
        this.get('model').loadEmailDomains(true)
      );
    },


  }

});
