Threadable.IntegrationTrelloSetupView = Ember.View.extend({
  tagName: 'div',
  templateName: 'integration_trello_setup',

  trelloBoards: null,

  authorization: function() {
    return this.get('context.currentUser.externalAuthorizations').filter(function(auth) { return auth.provider == 'trello'; })[0];
  }.property('context.currentUser'),

  willInsertElement: function() {
    var auth = this.get('authorization');
    $.ajax({
      url: 'https://api.trello.com/1/members/' + auth.nickname + '?boards=all&board_fields=name&organizations=all&organization_fields=displayName&key=' + auth.application_key + '&token=' + auth.token,
      dataType: 'jsonp',
    }).done(function(response) {
      var boards = response.boards.map(function(board) {
        return {boardSpec: JSON.stringify({id: board.id, name: board.name}), name: board.name};
      });
      this.set('trelloBoards', boards);
    }.bind(this));
  }
});
