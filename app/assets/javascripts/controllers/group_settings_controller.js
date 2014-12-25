Threadable.GroupSettingsController = Ember.ObjectController.extend(
  Threadable.CurrentUserMixin,
  Threadable.ConfirmationMixin,
  {
  needs: ['organization', 'application'],

  error: null,
  currentUser: Ember.computed.alias('controllers.application.currentUser'),
  updateInProgress: false,

  nonMemberPostingTypes: [
    {prettyName: 'Allow non-members to create new conversations', method: 'allow'},
    {prettyName: 'Allow replies from non-members',                method: 'allow_replies'},
    {prettyName: 'Hold every message from non-members',           method: 'hold'}
  ],

  editableGroup: function() { return this.get('model').copy(); }.property('model'),

  descriptionLengthRemaining: function() {
    var description = this.get('editableGroup.description');
    if(description) {
      return 50 - this.get('editableGroup.description').replace(/\n/g, "\r\n").length;
    } else {
      return 50;
    }
  }.property('editableGroup.description'),

  canDelete: function() {
    if(this.get('primary')) {
      return false;
    }

    return this.get('controllers.organization.canRemoveNonEmptyGroup') ||
      this.get('conversationsCount') === 0;
  }.property('userId', 'controllers.organization.canRemoveNonEmptyGroup'),

  canSetGoogleSync: function() {
    return !! this.get('model.canSetGoogleSync') && this.get('controllers.organization.googleUser');
  }.property('currentUser'),

  aliasPlainAddress: function() {
    var aliasEmailAddress = this.get('editableGroup.aliasEmailAddress');
    if(aliasEmailAddress.match(/<(.*)>/)) {
      return RegExp.$1;
    }
    if(aliasEmailAddress.match(/@/)) {
      return aliasEmailAddress;
    }
    return '';
  }.property('editableGroup.aliasEmailAddress'),

  aliasTaskAddress: function() {
    return this.get('aliasPlainAddress').replace(/@/, '-task@');
  }.property('aliasPlainAddress'),

  allowNonMemberPosting: function() {
    return this.get('nonMemberPosting') == 'allow';
  }.property('nonMemberPosting'),

  allowNonMemberReplies: function() {
    return this.get('nonMemberPosting') == 'allow_replies';
  }.property('nonMemberPosting'),

  holdNonMemberPosting: function() {
    return this.get('nonMemberPosting') == 'hold';
  }.property('nonMemberPosting'),

  actions: {
    deleteGroup: function() {
      this.confirm({
        message: 'Are you sure you want to delete the '+this.get('name')+' group?',
        description: 'This will move all conversations only in this group to the primary group',
        approveText: 'Delete',
        declineText: 'cancel',
        approved: function() {
          var group = this.get('model');
          group.deleteRecord().then(function() {
            this.get('controllers.organization.groups').removeObject(group);
            this.transitionTo('conversations', 'my');
          }.bind(this));
        }.bind(this)
      });
    },
    updateGroup: function() {
      this.set('error', null);
      this.set('updateInProgress', true);

      var group = this.get('model');
      group.setProperties({
        description:       this.get('editableGroup.description'),
        subjectTag:        this.get('editableGroup.subjectTag'),
        color:             this.get('editableGroup.color'),
        autoJoin:          this.get('editableGroup.autoJoin'),
        nonMemberPosting:  this.get('editableGroup.nonMemberPosting'),
        aliasEmailAddress: this.get('editableGroup.aliasEmailAddress'),
        webhookUrl:        this.get('editableGroup.webhookUrl'),
        googleSync:        this.get('editableGroup.googleSync'),
      });

      group.saveRecord().then(groupSaved.bind(this), error.bind(this));

      function groupSaved(response) {
        group.deserialize(response.group);
        this.send('transitionToGroup', group);
        this.set('updateInProgress', false);
      }

      function error(response) {
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
        this.set('updateInProgress', false);
      }
    },

    toggleAdvanced: function() {
      this.set('editAdvanced', ! this.get('editAdvanced'));
    }
  }

});
