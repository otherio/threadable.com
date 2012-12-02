Multify.Views.Layout = Backbone.View.extend({

  initialize: function(){
    // var view = this;
    // Multify.on('logout', function(){ view.render(); });
    // Multify.on('login', function(){ view.render(); });
    // Multify.router.on("route:project", this.selectProject.bind(this));
  },

  el: document.body,

  render: function(){

    console.warn('RE RENDERING ENTIRE LAYOUT');

    this.options = {};

    this.options.logged_in = Multify.logged_in;
    this.options.current_user = Multify.current_user;

    var html = Multify.render('layout', this.options);

    this.$el.html(html);

    this.renderPageContent();

    this.$('a.logout').click(function(){ Multify.logout(); });

    this.$('a.login').click(function(){
      Multify.login('jared@change.org', 'password');
    });

    return this;
  },

  renderPageContent: function(){
    var $content = this.$('#page > .content');

    if (Multify.logged_in){
      this.dashboard = new Multify.Views.Dashboard(this.options);
      $content.html(this.dashboard.render().el);
    }else{
      $content.html(Multify.render('splash'));
    }

  },

});
