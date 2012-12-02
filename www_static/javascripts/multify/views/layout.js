Multify.Views.Layout = Backbone.View.extend({
  initialize: function(){
    var view = this;
    Multify.on('logout', function(){ view.render(); });
    Multify.on('login', function(){ view.render(); });
    this.render();
  },

  el: document.body,

  render: function(){
    var html = Multify.templates.layout({projects:TEMP_FAKE_PROJECTS});
    this.$el.html(html);

    this.mainProjectList = new Multify.Views.MainProjectList({
      projects: this.options.projects
    });

    this.$('.main-project-list').replaceWith(this.mainProjectList.el);

    this.$('a.logout').click(function(){ Multify.logout(); });

    this.$('a.login').click(function(){
      Multify.login('jared@change.org', 'password');
    });

  }
});
