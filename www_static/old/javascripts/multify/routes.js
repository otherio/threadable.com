Multify.routes = {

  project: function(project_slug){
    if (project_slug instanceof Multify.Project)
      project_slug = project_slug.get('slug');
    return '/projects/'+project_slug;
  },


}
