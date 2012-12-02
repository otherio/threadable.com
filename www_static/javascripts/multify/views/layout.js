Multify.Views.Layout = Backbone.View.extend({
  initialize: function(){
    this.render();
  },

  render: function(){
    var html = Multify.templates.layout({projects:TEMP_FAKE_PROJECTS});
    this.$el.html(html);

    this.mainProjectList = new Multify.Views.MainProjectList({
      projects: this.options.projects
    });

    this.$('.main-project-list').replaceWith(this.mainProjectList.el);

  }
});
