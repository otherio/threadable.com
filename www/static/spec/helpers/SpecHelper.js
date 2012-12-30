beforeEach(function() {

  var multify = require('multify');
  // jasine.Ajax doesn't work with cross-domain ajax, so make it same-domain
  multify.host = location.protocol + '//' + location.host;
  multify.dataType = 'json';
  multify.attributes = {};

  multify.session.clear({silent:true});
  multify.session.save();

  Backbone.history = jasmine.createSpyObj('Backbone.history', [
    'start', 'loadUrl', 'route', 'navigate']);
  Backbone.history.handlers = ['some', 'handlers'];

  jasmine.Ajax.useMock();
  clearAjaxRequests();

  // spy on $.cookie() and return some plausible session value

  this.setCurrentUser = function(current_user, options){
    options || (options={})
    if (typeof options.silent === 'undefined') options.silent = true;
    multify.set('current_user', current_user, options);
  }

});

afterEach(function(){
  $('#body').empty();
});
