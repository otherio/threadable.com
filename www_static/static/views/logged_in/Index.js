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

    show: function(options){
      console.log('rendering logged in index view', arguments);

      var
        layout = this,
        currentUser = App.Multify.get('currentUser'),
        projects = currentUser.projects,
        feed = currentUser.feed,
        // tasks = currentUser.tasks;
        slug, project, projectView;

      console.log('projects loaded?', !!projects.loaded);

      if (projects.loaded){
        render()
      }else{
        projects.on('reset', render)
      }

      function render(){
        projects.off('reset', render)
        // render the list of projects if it's not already rendered
        if (!layout.projects.currentView){
          layout.projects.show(new ProjectsView({
            projects: projects,
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
      }


    }

  });

  function getProjects(){
    return App.Multify.get('currentUser').projects
  }



});
