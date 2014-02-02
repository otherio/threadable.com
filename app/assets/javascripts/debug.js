// Ember.onerror = function(error){
//   console.error(error);
//   debugger;
//   throw error;
// };

function lookup(name) {
  return Threadable.__container__.lookup(name);
}
function modelFor(route_name) {
  return lookup('route:application').modelFor(route_name);
}
function store(){
  return lookup('store:main');
}
function controllerFor(name){
  return lookup("controller:"+name);
}
function currentUser(){
  return controllerFor('application').get('currentUser');
}


Threadable.currentWindowSize = undefined;
$(window).on('resize', function(){
  var width = $(window).width();
  var size = (
    width < 768  ? 'small ' :
    width < 1280 ? 'medium' :
                   'large '
  );

  Threadable.currentWindowSize = Threadable.currentWindowSize || size;
  if (Threadable.currentWindowSize !== size){
    console.log('transitioning from '+Threadable.currentWindowSize+' to '+size+' at '+width+'px');
    // TODO we should trigger an event here
    Threadable.currentWindowSize = size;
  }

});
