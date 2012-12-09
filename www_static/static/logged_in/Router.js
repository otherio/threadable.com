define(function(require){

  var Marionette = require('marionette');
  var IndexView = require('views/logged_in/index');

  return Marionette.AppRouter.extend({

    appRoutes: {
      ""                             : "home",
      ":projectSlug"                 : "project",
      ":projectSlug/tasks"           : "projectTasks",
      ":projectSlug/tasks/:taskSlug" : "projectTask",
      "tasks"                        : "tasks",
      "tasks/:taskSlug"              : "task",
      "*defaults"                    : "missing"
    },

    controller: {
      home: function(){
        console.log('ROUTE HANDLER: home', arguments);
        view().show({view:'home'})
      },
      project: function(projectSlug){
        console.log('ROUTE HANDLER: project', arguments);
        view().show({view:'project', projectSlug: projectSlug});
      },
      projectTasks: function(projectSlug){
        console.log('ROUTE HANDLER: projectTasks', arguments);
        view().show({view:'projectTasks', projectSlug: projectSlug});
      },
      projectTask: function(projectSlug, taskSlug){
        console.log('ROUTE HANDLER: projectTask', arguments);
        view().show({view:'projectTask', projectSlug: projectSlug, taskSlug: taskSlug});
      },
      tasks: function(){
        console.log('ROUTE HANDLER: tasks', arguments);
        view().show({view:'tasks'})
      },
      task: function(taskSlug){
        console.log('ROUTE HANDLER: task', arguments);
        view().show({view:'task', taskSlug: taskSlug});
      },

      missing: function(path){
        console.warn('no route matches',path);
        App.router.navigate("/", {trigger:true});
      }
    }

  });

  // private

  function view(){
    var view = App.layout.main.currentView;
    (view && view instanceof IndexView) || App.layout.main.show(view = new IndexView);
    return view;
  }

});
