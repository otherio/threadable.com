Multify.View  = {
  templates: {},

  render: function(name, data) {
    return this.templates[name].render(data);
  }
};
