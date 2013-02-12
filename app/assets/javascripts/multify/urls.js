Multify.project_path = function(project){
  project || (project = ENV.project)
  if ('slug' in project) project = project.slug;
  return '/'+project;
}

Multify.project_members_path = function(project){
  return Multify.project_path(project)+'/members';
}
