Threadable.ConversationController = Ember.ObjectController.extend(Threadable.ConfirmationMixin, {
  needs: ['doerSelector', 'group'],

  showDoerSelector: false,

  unselectedGroups: function() {
    var groups = Ember.ArrayProxy.create({content:[]});
    groups.addObjects(this.get('organization.groups'));
    groups.removeObjects(this.get('groups'));
    return groups;
  }.property('allGroups.length', 'groups.length'),

  addGroup: function(group) {
    var groups = this.get('groups');
    if (typeof group === 'string') group = this.get('organization.groups').findBy('slug', group);
    if (!group) return;
    if (groups.indexOf(group) === -1) groups.pushObject(group);
  },

  actions: {
    convertToTask: function(){
      var controller = this;
      if (controller.get('isTask')) return;
      controller.confirm({
        message: "Are you sure you want to convert this conversation to a task?",
        approveText: 'Convert to task',
        declineText: 'cancel',
        approved: function() {
          controller.set('task', true);
          controller.get('content').saveRecord();
        }
      });
    },
    convertToConversation: function(){
      var controller = this;
      if (!controller.get('isTask')) return;
      controller.confirm({
        message: "Are you sure you want to convert this task to a conversation?",
        approveText: 'Convert to conversation',
        declineText: 'cancel',
        approved: function() {
          controller.set('task', false);
          controller.get('content').saveRecord().then(function() {
            // TODO clear out any pending doers - Jared
          });
        }
      });
    },
    toggleDoerSelector: function() {
      this.toggleProperty('showDoerSelector');
    },
    toggleComplete: function() {
      var conversation = this.get('content');
      conversation.set('done', !conversation.get('done'));
      conversation.saveRecord().then(function() {
        conversation.loadEvents(true);
      }.bind(this));
    },
    toggleMuted: function() {
      var conversation = this.get('content');
      conversation.set('muted', !conversation.get('muted'));
      conversation.saveRecord();
    },
    removeGroup: function(group) {
      this.confirm({
        message: (
          "Are you sure you want to remove this " +
          (this.get('task') ? 'task' : 'conversation') + ' from the +' +
          group.get('name') + ' group? Group members will no longer receive new messages via email.'
        ),
        approveText: 'remove',
        declineText: 'cancel',
        approved: function() {
          var conversation = this.get('content');
          conversation.get('groupIds').removeObject(group.get('id'));

          // this should not be necessary, but ember-restless doesn't detect the array change
          conversation.set('isDirty', true);

          conversation.saveRecord().then(function() {
            conversation.loadEvents(true);
          }.bind(this));
        }.bind(this)
      });
    },
    addGroup: function(group) {
      var conversation = this.get('content');
      conversation.get('groupIds').pushObject(group.get('id'));

      // this should not be necessary, but ember-restless doesn't detect the array change
      conversation.set('isDirty', true);

      conversation.saveRecord().then(function(response) {
        conversation.loadEvents(true);
      }.bind(this));
    }
  }
});
