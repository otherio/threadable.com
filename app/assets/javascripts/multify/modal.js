Multify.Modal = {
  current: function(){
    return $('.modal:visible:last');
  }
};


Multify.Modal.Flash = {

  append: function(alert){
    Multify.Modal.current().find('.flash_messages:first').append(alert);
    return alert;
  },

  message: function(content){
    return this.append(Multify.Flash.create('message', content));
  },

  error: function(content){
    return this.append(Multify.Flash.create('error', content));
  },

  notice: function(content){
    return this.append(Multify.Flash.create('notice', content));
  },

  alert: function(content){
    return this.append(Multify.Flash.create('alert', content));
  }

};
