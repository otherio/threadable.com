Multify.Model = Backbone.Model.extend({

});

// create:
//   M('User', {});
// get:
//   User = M('User');
// make:
//   user = new M('User');
function M(name, extension){
  var model = Multify[name], modelName, resourceName;
  if (model === undefined){
    modelName = underscore(name)
    resourceName = modelName+'s';
    model = Multify.Model.extend({
      modelName:    modelName,
      resourceName: resourceName,
      path:         '/'+resourceName
    });
    Multify[name] = model;
  }
  if (arguments.length > 1) model.extend(extension);
  return model;
};
