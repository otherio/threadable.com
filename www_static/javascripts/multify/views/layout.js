Multify.Views.Layout = Backbone.View.extend({
  initialize: function(){
    this.render();
  },

  render: function(){
    var html = Multify.templates.layout({projects:TEMP_FAKE_PROJECTS});
    this.$el.html(html);

    this.projectsView = new Multify.Views.Projects({
      el: this.$('.list-of-projects'),
      projects: TEMP_FAKE_PROJECTS
    });

  }
});
