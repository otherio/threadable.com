Covered.ComposeController = Ember.ObjectController.extend({
  needs: ['organization', 'group'],

  actions: {
    sendMessage: function() {
      var organization_slug = this.get('controllers.organization').get('content').get('slug');
      var group_slug = this.get('controllers.group').get('content').get('slug');

      var message = this.get('content');
      var conversation = Covered.Conversation.create({
        subject: this.get('subject'),
        organization_id: organization_slug,
        group_ids: group_slug, // eventually this will be settable in the UI
        task: message.get('composing') === 'task'
      });

      conversation.saveRecord().then(function(response) {
        message.set('conversation_id', response.conversation.slug);
        message.set('organization_id', organization_slug);

        message.saveRecord().then(function(response) {
          this.transitionToRoute('conversations', organization_slug, group_slug);
        }.bind(this), function(response){
          console.log('we would handle an error in saving the message here: ', response);
        });
      }.bind(this), function(response) {
        console.log('we would handle an error in saving the conversation here: ', response);
      });
    }
  }
});
