define(function(require) {
  var
    Marionette = require('marionette'),
    template = require('text!templates/logged_in/index/projects.html'),
    ListView = require('views/logged_in/index/projects/list');

  return Backbone.Marionette.Layout.extend({
    template: _.template(template),

    regions:{
      list: '> ul > li.list'
    },

    onRender: function(){
      console.log('rendering main projects');
      this.list.show(new ListView({collection: this.options.projects}))
      this.selectProject(this.options.selectedProject);
    },

    selectProject: function(selectedProject){
      this.list.currentView.selectProject(selectedProject);
      return this;
    }

  });

});
