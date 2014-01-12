function lookup(name) {
  return Covered.__container__.lookup(name);
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
function ApplicationController(){
  return controllerFor('application');
}
function OrganizationController(){
  return controllerFor('organization');
}
function GroupsController(){
  return controllerFor('groups');
}
function GroupController(){
  return controllerFor('group');
}
function ConversationController(){
  return controller('conversation');
}
function currentUser(){
  return ApplicationController().get('currentUser');
}


Covered.currentWindowSize = undefined;
$(window).on('resize', function(){
  var width = $(window).width();
  var size = (
    width < 479  ? 'min' :
    width < 767  ? 'small' :
    width < 959  ? 'medium' :
    width < 1199 ? 'large' :
                   'x-large'
  );

  Covered.currentWindowSize = Covered.currentWindowSize || size;
  if (Covered.currentWindowSize !== size){
    console.log('transitioning from '+Covered.currentWindowSize+' to '+size);
    // TODO we should trigger an event here
    Covered.currentWindowSize = size;
  }

});
