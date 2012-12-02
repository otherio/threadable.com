Multify.Project = Backbone.Model.extend({
  name: null,
  slug: null
});


Multify.Project.all = function(callback){

  if (Multify.logged_in){

    Multify.get('/projects')
      .success(function(projects){
        callback(new Multify.Projects(projects));
      })
      .fail(function(){
        console.error('failed to load projects');
      })
    ;

  }else{
    setTimeout(function(projects){
      callback(new Multify.Projects);
    });
  }

}
