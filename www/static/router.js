define(function(require){

  var Marionette = require('marionette');

  var Router = Marionette.AppRouter.extend({

    appRoutes: {
      ""                                        : "home",
      "projects"                                : "projects",
      "projects/:project_slug"                  : "project",
      "projects/:project_slug/tasks"            : "project_tasks",
      "projects/:project_slug/tasks/:task_slug" : "project_task",
      "tasks"                                   : "tasks",
      "tasks/:task_slug"                        : "task",
      "*defaults"                               : "missing"
    },

    controller: {
      home:          inspector('home'),
      projects:      inspector('projects'),
      project:       inspector('project'),
      project_tasks: inspector('project_tasks'),
      project_task:  inspector('project_task'),
      tasks:         inspector('tasks'),
      task:          inspector('task'),
      missing: function(path){
        console.warn('no route matches',path);
        App.router.navigate("/", {trigger:true});
      }
    }

  });

  return new Router();

});
