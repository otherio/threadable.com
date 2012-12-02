Multify.Views.Layout = Backbone.View.extend({

  initialize: function(){
    var view = this;
    Multify.on('logout', function(){ view.render(); });
    Multify.on('login', function(){ view.render(); });
    Multify.router.on("route:project", function(){
      this.main_project_list.setActiveLink()
    }.bind(this));
  },

  el: document.body,

  render: function(){

    console.warn('RE RENDERING ENTIRE LAYOUT');

    this.options = {};

    this.options.logged_in = Multify.logged_in;
    this.options.current_user = Multify.current_user;

    var html = Multify.templates.layout(this.options);

    this.$el.html(html);

    this.renderMainProjectsList();

    this.renderMainProjectsPanel();

    this.$('a.logout').click(function(){ Multify.logout(); });

    this.$('a.login').click(function(){
      Multify.login('jared@change.org', 'password');
    });

    return this;
  },


  renderMainProjectsList: function(){
    var
      view = this;

    this.main_project_list = new Multify.Views.MainProjectList({
      el: view.$('.main-project-list'),
      projects: this.options.current_user.projects
    });

    this.options.current_user.projects.fetch();
  },

  renderMainProjectsPanel: function(){
    this.main_project_panel = new Multify.Views.MainProjectPanel();
    this.main_project_panel.render();
    this.$('.panels > .main').html(this.main_project_panel.el);
  }
});
