beforeEach(function() {

  var Multify = require('Multify');
  // jasine.Ajax doesn't work with cross-domain ajax, so make it same-domain
  Multify.host = location.protocol + '//' + location.host;
  Multify.dataType = 'json';
  Multify.attributes = {};

  Multify.session.clear({silent:true});
  Multify.session.save();

  Backbone.history = jasmine.createSpyObj('Backbone.history', [
    'start', 'loadUrl', 'route']);
  Backbone.history.handlers = ['some', 'handlers'];

  jasmine.Ajax.useMock();
  clearAjaxRequests();

  // spy on $.cookie() and return some plausible session value

});

afterEach(function(){
  $('#body').empty();
});
