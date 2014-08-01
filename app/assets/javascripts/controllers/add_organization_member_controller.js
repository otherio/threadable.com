Threadable.AddOrganizationMemberController = Ember.ObjectController.extend(Threadable.CurrentUserMixin, {
  needs: ['organization', 'organization_members'],

  organization: Ember.computed.alias('controllers.organization'),

  autoJoinGroups: function() {
    return this.get('organization.groups').filterBy('autoJoin', true);
  }.property('organization.groups'),

  actions: {
    addMember: function() {
      var member = this.get('content');
      var organization = this.get('controllers.organization');

      member.set('organizationSlug', organization.get('slug') );

      member.saveRecord().then(
        memberSaved.bind(this),
        memberFailed.bind(this)
      );

      function memberSaved(response) {
        member.deserialize(response);
        this.get('controllers.organization_members').pushObject(member);
        this.send('transitionToOrganizationMembers', organization);
      }

      function memberFailed(xhr) {
        error.call(this, xhr);
      }

      function error(response) {
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
      }

    },

    reset: function() {
      this.set('emailAddress', null);
      this.set('name', null);
      this.set('personalMessage', null);
    },
  }
});
