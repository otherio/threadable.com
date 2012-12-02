Multify.Views.Projects = Backbone.View.extend({
  initialize: function(){
    this.render();
  },
  render: function(){
    var html = Multify.templates.projects({
      projects: this.options.projects
    });
    this.$el.html(html);
  }
});
