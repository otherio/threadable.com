Threadable.GroupDeliveryOptionsController = Ember.ObjectController.extend(
  Threadable.CurrentUserMixin,
  {
  needs: ['organization', 'application'],

  error: null,
  group: null,

  currentUser: Ember.computed.alias('controllers.application.currentUser'),
  updateInProgress: false,

  deliveryMethods: [
    {prettyName: 'Send each message',                  method: 'gets_each_message'},
    {prettyName: 'Daily summary',                      method: 'gets_in_summary'},
    {prettyName: 'First message of each conversation', method: 'gets_first_message'}
  ],

  autoSave: function() {
    if (this.get('saving')) return;
    this.save();
  }.observes('deliveryMethod'),

  getsEachMessage: function() {
    return this.get('deliveryMethod') == 'gets_each_message';
  }.property('deliveryMethod'),
  getsFirstMessage: function() {
    return this.get('deliveryMethod') == 'gets_first_message';
  }.property('deliveryMethod'),
  getsInSummary: function() {
    return this.get('deliveryMethod') == 'gets_in_summary';
  }.property('deliveryMethod'),

  save: function() {
    var controller = this;
    if (controller.get('saving')) return;
    controller.set('saving', true);
    controller.get('model').saveRecord().then(
      function() {
        controller.set('saving', false);
      },
      function() {
        controller.set('saving', false);
      }
    );
  }

});
