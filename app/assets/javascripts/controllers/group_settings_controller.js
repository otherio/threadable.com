Threadable.GroupSettingsController = Ember.ObjectController.extend(Threadable.CurrentUserMixin, {
  needs: ['organization'],

  editableGroup: function() { return this.get('model').copy(); }.property('model'),

  aliasPlainAddress: function() {
    var aliasAddress = this.get('editableGroup.aliasAddress');
    if(aliasAddress.match(/\<(.*)\>/)) {
      return RegExp.$1;
    }
    if(aliasAddress.match(/@/)) {
      return aliasAddress;
    }
    return '';
  }.property('editableGroup.aliasAddress'),

  aliasTaskAddress: function() {
    return this.get('aliasPlainAddress').replace(/@/, '-task@');
  }.property('aliasPlainAddress'),

  actions: {
    updateGroup: function() {
      var group = this.get('content');
      group.setProperties({
        subjectTag:   this.get('editableGroup.subjectTag'),
        color:        this.get('editableGroup.color'),
        autoJoin:     this.get('editableGroup.autoJoin'),
        holdMessages: this.get('editableGroup.holdMessages'),
        aliasAddress: this.get('editableGroup.aliasAddress'),
      });

      group.saveRecord().then(
        groupSaved.bind(this),
        error.bind(this)
      );

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
