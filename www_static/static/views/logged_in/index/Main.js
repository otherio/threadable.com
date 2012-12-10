define(function(require) {
  var
    Marionette   = require('marionette'),
    template     = require('text!templates/logged_in/index/main.html');
    //ProjectsView = require('views/logged_in/index/projects'),
    //FeedView     = require('views/logged_in/index/feed'),
    //MainView     = require('views/logged_in/index/main');

  return Marionette.Layout.extend({
    template: _.template(template),

    className: 'main',

    regions:{
      // TODO change this to a region per tab content
      // tabs:    '> .tabs',
      // folders: '> .folders'
    },

    initialize: function(){
      if (!this.options.projectSlug)
        throw new Error('projectSlug cannot be blank. '+this.options.projectSlug);
    },

    // onBeforeRender: function(){
    //   var slug = this.options.projectSlug;
    //   return this.model = this.projects.find(function(project){
    //     return project.get('slug') === slug;
    //   });
    // },

    serializeData: function(){
      return {slug: this.options.projectSlug};
    },

    onRender: function(){
      this.$('> .tabs > li.'+this.options.activeTab).addClass('active');
    }

  });


});
