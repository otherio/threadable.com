function store(){
  return Covered.__container__.lookup('store:main');
}

function controller(name){
  return Covered.__container__.lookup("controller:"+name);
}

function currentUser(){
  return controller('application').get('currentUser');
}
function currentOrganization(){
  return controller('application').get('currentOrganization');
}
function currentConversation(){
  return controller('application').get('currentConversation');
}
function currentGroup(){
  return controller('application').get('currentGroup');
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
