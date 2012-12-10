define(function(require) {
  var
    Marionette   = require('marionette'),
    template     = require('text!templates/logged_in/index.html'),
    ProjectsView = require('views/logged_in/index/projects'),
    FeedView     = require('views/logged_in/index/feed'),
    MainView     = require('views/logged_in/index/main');

  return Marionette.Layout.extend({
    className: 'index',

    regions:{
      projectsRegion: '.panels > .left .projects',
      feedRegion:     '.panels > .left .feed',
      mainRegion:     '.panels > .main',
    },

    initialize: function(){
      this.currentUser = App.Multify.get('currentUser');
      this.projects = this.currentUser.projects;
      this.feed = this.currentUser.feed;
    },

    delayShow: function(options){
      console.log('delaying show');
      var show = function(){
        this.projects.off('reset', show); // unbind
        this.render().show(options); // rerender and show
      }.bind(this);
      this.projects.on('reset', show);
      return this;
    },

    show: function(options){
      if (!this.projects.loaded) return this.delayShow(options);
      console.log('rendering logged in index view', arguments);

      // render the list of projects if it's not already rendered
      if (!this.projectsRegion.currentView){
        this.projectsRegion.show(new ProjectsView({
          projects: this.projects,
          selectedProject: options.projectSlug
        }));
      }else{
        this.projectsRegion.currentView.selectProject(options.projectSlug);
      }

      // render the list of projects if it's not already rendered
      this.feedRegion.currentView || this.feedRegion.show(new FeedView({collection: this.feed}));

      if (options.projectSlug){
        options.model = this.projects.findBySlug(options.projectSlug);
        this.mainRegion.show(new MainView(options));
      }

    },

    getTemplate: function(){
      return this.projects.loaded ? _.template(template) : _.template("<h1>Loading...</h1>");
    }

  });

  function getProjects(){
    return App.Multify.get('currentUser').projects
  }



});
