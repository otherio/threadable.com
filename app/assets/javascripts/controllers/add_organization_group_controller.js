Threadable.AddOrganizationGroupController = Ember.ObjectController.extend(Threadable.CurrentUserMixin, {
  needs: ['organization'],

  integrations: [
    {name: "Standard (conversation/task)", id: ''},
    {name: "Trello",                       id: 'trello'}
  ],

  integration: '',

  editingEmailAddressTag: false,
  editingSubjectTag: false,

  calculatedEmailAddressTag: function() {
    var name = this.get('name') || '';

    // compress all invalid characters into a single dash
    var tag = name.replace(/[^0-9A-Za-z]+/g, '-').toLowerCase().substr(0,15);

    // remove leading and trailing dashes
    return tag.replace(/\-+$/, '').replace(/^\-+/, '');
  }.property('name'),

  calculatedSubjectTag: function() {
    var name = this.get('name') || '';
    var tag = name.replace(/[^\w]+/g, '-').substr(0,8);
    return tag.replace(/\-+$/, '').replace(/^\-+/, '');
  }.property('name'),

  calculatedEmailAddress: function() {
    var name = this.get('name') || '';
    var whichTag = this.get('editingEmailAddressTag') ? 'emailAddressTag' : 'calculatedEmailAddressTag';

    return this.get('controllers.organization.slug') + '+' + this.get(whichTag) + '@threadable.com';
  }.property('name', 'emailAddressTag'),

  actions: {
    editEmailAddressTag: function() {
      this.set('editingEmailAddressTag', true);
      this.set('emailAddressTag', this.get('calculatedEmailAddressTag'));
    },

    editSubjectTag: function() {
      this.set('editingSubjectTag', true);
      this.set('subjectTag', this.get('calculatedSubjectTag'));
    },

    createGroup: function() {
      var group = this.get('content');

      if(!this.get('editingSubjectTag')) {
        group.set('subjectTag', this.get('calculatedSubjectTag'));
      }

      if(!this.get('editingEmailAddressTag')) {
        group.set('emailAddressTag', this.get('calculatedEmailAddressTag'));
      }

      group.set('organizationSlug', this.get('controllers.organization.content.slug'));

      group.saveRecord().then(
        groupSaved.bind(this),
        error.bind(this)
      );

      function groupSaved(response) {
        group.deserialize(response.group);
        this.get('controllers.organization.groups').pushObject(group);
        if (group.get('autoJoin')){
          this.send('transitionToGroupCompose', group);
        }else{
          this.send('transitionToGroupMembers', group);
        }
      }

      function error(response) {
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
      }
    }
  }

});
