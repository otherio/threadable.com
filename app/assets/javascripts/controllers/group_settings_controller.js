Threadable.GroupSettingsController = Ember.ObjectController.extend(
  Threadable.CurrentUserMixin,
  Threadable.ConfirmationMixin,
  {
  needs: ['organization'],

  error: null,

  editableGroup: function() { return this.get('model').copy(); }.property('model'),

  aliasPlainAddress: function() {
    var aliasEmailAddress = this.get('editableGroup.aliasEmailAddress');
    if(aliasEmailAddress.match(/\<(.*)\>/)) {
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

  actions: {
    deleteGroup: function() {
      this.confirm({
        message: 'Are you sure you want to delete the '+this.get('name')+' group?',
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

      var group = this.get('content');
      group.setProperties({
        subjectTag:        this.get('editableGroup.subjectTag'),
        color:             this.get('editableGroup.color'),
        autoJoin:          this.get('editableGroup.autoJoin'),
        holdMessages:      this.get('editableGroup.holdMessages'),
        aliasEmailAddress: this.get('editableGroup.aliasEmailAddress'),
        webhookUrl:        this.get('editableGroup.webhookUrl'),
      });

      group.saveRecord().then(groupSaved.bind(this), error.bind(this));

      function groupSaved(response) {
        group.deserialize(response.group);
        this.send('transitionToGroup', group);
      }

      function error(response) {
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
      }
    },

    toggleAdvanced: function() {
      this.set('editAdvanced', ! this.get('editAdvanced'));
    }
  }

});
