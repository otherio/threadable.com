Rails.Widget.curry = function(property, preventDefault){
  var Widget = this;
  return function(event) {
    if (preventDefault) event.preventDefault();
    $(this).widget(Widget)[property]();
  }
}

Rails.Widget.prototype.page = function(){
  var page = this.node.data('page');
  if (!page){
    page = this.node.parents('.page').data('page');
    this.node.data('page', page);
  }
  return page;
};
