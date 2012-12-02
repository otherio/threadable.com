Multify.Views.Dashboard = Backbone.View.extend({

  className: 'dashboard',

  initialize: function(){
    this.current_user = this.options.current_user;
    this.projects = this.options.current_user.projects;

    Multify.router.on("route:project", function(project_slug, tab){
      this.selectProject(project_slug, tab);
    }.bind(this));
  },

  render: function(){
    var html = Multify.render('dashboard');

    this.$el.html(html);

    this.project_list = new Multify.Views.Dashboard.ProjectList({
      el: this.$('.dashboard-project-list'),
      projects: this.projects
    });

    if (this.projects.isEmpty()){
      this.projects_fetch = this.projects.fetch();
    }else{
      this.project_list.render();
    }

    return this;
  },

  renderProjectsPanel: function(project){
    this.project_panel = new Multify.Views.Dashboard.ProjectPanel({
      el: this.$('.dashboard-project-panel'),
      project: project
    });
    this.project_panel.render();
  },

  selectProject: function(project_slug, tab){
    if (!Multify.logged_in) return;
    var project = this.options.current_user.projects.find(function(project){
      return project.get('slug') == project_slug;
    });
    console.log('SELECTING PROJECT', project_slug, project);

    if (project === undefined){
      this.projects_fetch.done(function(){
        this.selectProject(project_slug, tab);
      }.bind(this))
      return false;
    }
    this.renderProjectsPanel(project);
    this.project_list.setActiveLink();
    if (tab) this.project_panel.selectTab(tab);
    return true;
  },


});
