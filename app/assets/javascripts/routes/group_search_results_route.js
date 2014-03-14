Threadable.GroupSearchResultsRoute = Ember.Route.extend({

  model: function(params) {
    var query        = params.query;
    var organization = this.modelFor('organization');
    var group        = this.modelFor('group');
    return new Ember.RSVP.Promise(function(resolve, reject) {

      if (query.length < 3) return resolve([]);

      var request = $.getJSON('/api/conversations/search',{
        q:               params.query,
        organization_id: this.modelFor('organization').get('id'),
        group:           group,
      });

      request.done(function(response) {
        conversations = response.conversations.map(function(conversation){
          conversation = Threadable.Conversation.create().deserialize(conversation);
          conversation.set('organization', organization);
          Threadable.Conversation.cache(conversation);
          return conversation;
        })
        resolve(conversations);
      });

      request.fail(reject);
    });
  },


  renderTemplate: function() {
    this.render('group_search_results', {into: 'group_search', outlet: 'results'});
  },

});
