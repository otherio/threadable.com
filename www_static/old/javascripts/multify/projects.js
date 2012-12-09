Multify.Projects = Backbone.Collection.extend({

  model: Multify.Project,

  findBySlug: function(slug){
    return this.find(function(project){
      return project.get('slug') === slug;
    });
  }

});


Multify.Projects.path = 'projects';
