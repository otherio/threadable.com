Backbone.Model.prototype.path = function(){
  return this.isNew() ?
    this.constructor.path :
    this.constructor.path+'/'+(this.param || this.id);
};

Backbone.Collection.prototype.path = function(){
  return this.constructor.path;
};
