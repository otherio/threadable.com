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

    if (Multify.logged_in){

      this.options.projects = new Multify.Projects([
        new Multify.Project({
          name:'love steve',
          slug:'love-steve'
        }),
        new Multify.Project({
          name:'eat sally',
          slug:'eat-sally'
        }),
        new Multify.Project({
          name:'pickup mustard',
          slug:'pickup-mustard'
        })
      ]);

    }else{
      this.options.projects = new Multify.Projects([]);
    }


    var html = Multify.templates.layout(this.options);

    this.$el.html(html);

    this.mainProjectList = new Multify.Views.MainProjectList({
      projects: this.options.projects
    });

    this.$('.main-project-list').replaceWith(this.mainProjectList.el);

    this.$('a.logout').click(function(){ Multify.logout(); });

    this.$('a.login').click(function(){
      Multify.login('jared@change.org', 'password');
    });

    return this;
  }
});
