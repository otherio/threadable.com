define(function(require) {
  var
    Marionette   = require('marionette'),
    template     = require('text!logged_in/index.html'),
    ProjectsView = require('views/logged_in/index/Projects'),
    FeedView     = require('views/logged_in/index/Feed'),
    MainView     = require('views/logged_in/index/Main');

  return Marionette.Layout.extend({
    className: 'index',

    regions:{
      projectsRegion: '.panels > .left .projects',
      feedRegion:     '.panels > .left .feed',
      mainRegion:     '.panels > .main',
    },

    initialize: function(){
      this.current_user = App.multify.get('current_user');
      this.projects = this.current_user.projects;
      this.feed = this.current_user.feed;
    },

    delayShow: function(options){
      var show = function(){
        this.projects.off('reset', show); // unbind
        this.render().show(options); // rerender and show
      }.bind(this);
      this.projects.on('reset', show);
      return this;
    },

    show: function(options){
      if (!this.projects.loaded) return this.delayShow(options);

      // render the list of projects if it's not already rendered
      if (!this.projectsRegion.currentView){
        this.initializeProjectsRegion(options.projectSlug);
      }else{
        this.projectsRegion.currentView.selectProject(options.projectSlug);
      }

      // render the list of feed items if it's not already rendered
      this.feedRegion.currentView || this.initializeFeedRegion();

      if (options.projectSlug) this.initializeMainRegion(options);
    },

    initializeProjectsRegion: function(projectSlug){
      var projectsView = new ProjectsView({
        projects: this.projects,
        selectedProject: projectSlug
      })
      this.projectsRegion.show(projectsView);
      return this;
    },

    initializeFeedRegion: function(){
      var feedView = new FeedView({collection: this.feed});
      this.feedRegion.show(feedView);
      return this;
    },

    initializeMainRegion: function(options){
      options.model = this.projects.findBySlug(options.projectSlug);
      if (!options.model){
        // this should probably be up in the controller
        App.router.navigate("/", {trigger:true});
        return;
      }
      var mainView = new MainView(options);
      this.mainRegion.show(mainView);
      return this;
    },

    getTemplate: function(){
      return this.projects.loaded ? _.template(template) : _.template("<h1>Loading...</h1>");
    }

  });

  function getProjects(){
    return App.multify.get('current_user').projects
  }

});
