beforeEach(function() {

  var Multify = require('Multify');
  // jasine.Ajax doesn't work with cross-domain ajax, so make it same-domain
  Multify.host = location.protocol + '//' + location.host;
  Multify.dataType = 'json';

  jasmine.Ajax.useMock();
  clearAjaxRequests();

  // spy on $.cookie() and return some plausible session value
});
