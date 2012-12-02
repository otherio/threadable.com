Multify.Views.MainProjectList = Backbone.View.extend({

  initialize: function(){
    this.render();
  },

  tagName: "ol",
  className: "main-project-list nav nav-list",

  render: function(){

    var view = this;

    var html = Multify.templates.main_project_list({
      projects: this.options.projects
    });

    Multify.router.on("route:project", function(project_slug){
      view.setActiveLink();
    });

    this.$el.html(html);
    view.setActiveLink();
  },

  setActiveLink: function(){
    active = this.$el.find('a[href="'+location.pathname+'"]').parent();
    active.addClass('active').siblings().removeClass('active');
  }
});
