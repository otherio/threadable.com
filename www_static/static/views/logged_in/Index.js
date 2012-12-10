define(function(require) {
  var
    Marionette   = require('marionette'),
    template     = require('text!templates/logged_in/index.html'),
    ProjectsView = require('views/logged_in/index/projects'),
    FeedView     = require('views/logged_in/index/feed'),
    MainView     = require('views/logged_in/index/main');

  return Marionette.Layout.extend({
    template: _.template(template),

    className: 'index',

    regions:{
      projects: '.panels > .left .projects',
      feed:     '.panels > .left .feed',
      main:     '.panels > .main',
    },


    onRender: function(){

    },

    show: function(options){
      console.log('SHOWING', arguments);

      var
        layout = this,
        currentUser = App.Multify.get('currentUser'),
        projects = currentUser.projects,
        feed = currentUser.feed,
        // tasks = currentUser.tasks;
        slug, project, projectView;

      if (projects.length === 0) projects.fetch();

      // render the list of projects if it's not already rendered
      if (!layout.projects.currentView){
        layout.projects.show(new ProjectsView({
          collection: projects,
          selectedProject: options.projectSlug
        }));
      }else{
        layout.projects.currentView.selectProject(options.projectSlug);
      }

      // render the list of projects if it's not already rendered
      layout.feed.currentView || layout.feed.show(new FeedView({collection: feed}));

      if (options.projectSlug){
        layout.main.show(new MainView(options));
      }

      // if (view === 'tasks'){

      //   // taskView = new TasksView({collection: tasks});
      //   // layout.main.show(taskView);

      //   return this;
      // }

      // if (view === 'task'){

      // }

      // if (view.match(/^project/)){
      //   slug = options.projectSlug;
      //   project = projects.find(function(p){ return p.get('slug') === slug; });
      // }

      // if (view === 'project'){
      //   projectView = layout.main.currentView;
      //   if (!projectView || projectView.model !== project){
      //     projectView = new ProjectView({model: project});
      //     layout.main.show(projectView);
      //   }
      // }

      // if (view === 'projectTasks'){

      // }

      // if (view === 'projectTask'){

      // }

    }

  });

  function getProjects(){
    return App.Multify.get('currentUser').projects
  }



});
