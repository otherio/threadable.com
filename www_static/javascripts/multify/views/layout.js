Multify.Views.Layout = Backbone.View.extend({

  initialize: function(){
    var view = this;
    Multify.on('logout', function(){ view.render(); });
    Multify.on('login', function(){ view.render(); });
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

    this.$('a.logout').click(function(){ Multify.logout(); });

    this.$('a.login').click(function(){
      Multify.login('jared@change.org', 'password');
    });

    return this;
  },


  renderMainProjectsList: function(){
    var
      view = this;

    this.mainProjectList = new Multify.Views.MainProjectList({
      el: view.$('.main-project-list'),
      projects: this.options.current_user.projects
    });

    this.options.current_user.projects.fetch();
  }
});
