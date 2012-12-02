Multify.Projects = Backbone.Collection.extend({

  model: Multify.Project,

  build: function(attributes){
    return new Multify.Project(attributes);
  },

  create: function(attributes){
    var
      projects = this,
      project  = projects.build(attributes);

    return project.save().done(function(){
      projects.add(project);
    });
  }

});


Multify.Projects.path = 'projects';
