define(function(require) {
  var
    Marionette = require('marionette'),
    ProjectsView = require('views/logged_in/index/projects'),
    ProjectView = require('views/logged_in/index/project'),
    // TasksView = require('views/logged_in/index/tasks'),
    // TaskView = require('views/logged_in/index/task'),
    template = require('text!templates/logged_in/index.html');

  return Marionette.Layout.extend({
    template: _.template(template),

    className: 'index',

    regions:{
      projects: '.panels > .left .projects',
      feed:     '.panels > .left .feed',
      main:     '.panels > .main',
      extra:    '.panels > .extra'
    },


    onRender: function(){

    },

    show: function(view, options){
      console.log('SHOWING', arguments);

      var
        layout = this,
        currentUser = App.Multify.get('currentUser'),
        projects = currentUser.projects,
        // tasks = currentUser.tasks;
        slug, project, projectView;

      if (projects.length === 0) projects.fetch();

      // render the list of projects if it's not already rendered
      layout.projects.currentView || layout.projects.show(new ProjectsView({collection: projects}));

      if (view === 'tasks'){

        // taskView = new TasksView({collection: tasks});
        // layout.main.show(taskView);

        return this;
      }

      if (view === 'task'){

      }

      if (view.match(/^project/)){
        slug = options.projectSlug;
        project = projects.find(function(p){ return p.get('slug') === slug; });
      }

      if (view === 'project'){
        projectView = layout.main.currentView;
        if (!projectView || projectView.model !== project){
          projectView = new ProjectView({model: project});
          layout.main.show(projectView);
        }
      }

      if (view === 'projectTasks'){

      }

      if (view === 'projectTask'){

      }

    }

  });

  function getProjects(){
    return App.Multify.get('currentUser').projects
  }



});
