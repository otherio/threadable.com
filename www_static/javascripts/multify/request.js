
Multify.request = function(method, path, params, options){
  params || (params = {});
  options || (options = {});
  params._method = method;
  if (Multify.logged_in){
    params.authentication_token = Multify.session.authentication_token
  }
  url = new URI(Multify.host)
  url.path = path;
  url.params = params;

  options = $.extend({}, {
    url: url.toString(),
    dataType: "jsonp",
    timeout: 2000,
  }, options);

  // console.log('REQUEST', options);

  return $.ajax(options);
};

Backbone.sync = function(action, model, options) {
  var
    method = ({'create':'POST', 'read':'GET', 'update':'PUT', 'delete':'DELETE'})[action],
    params = {};

  if (action === 'create' || action === 'update'){
    params[model.constructor.modelName] = model.toJSON();
  }

  // console.log('SYNC', action, model, options);

  return Multify.request(method, model.path(), params, {context: model})
    .done(options.success)
    .fail(options.error)
};
