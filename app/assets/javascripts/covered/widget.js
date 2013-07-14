Rails.Widget.prototype.page = function(){
  var page = this.node.data('page');
  if (!page){
    page = this.node.parents('.page').data('page');
    this.node.data('page', page);
  }
  return page;
};
