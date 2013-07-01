Covered.Modal = {
  current: function(){
    return $('.modal:visible:last');
  }
};


// Covered.Modal.Flash = {

//   append: function(alert){
//     Covered.Modal.current().find('.flash_messages:first').append(alert);
//     return alert;
//   },

//   message: function(content){
//     return this.append(Covered.Flash.create('message', content));
//   },

//   error: function(content){
//     return this.append(Covered.Flash.create('error', content));
//   },

//   notice: function(content){
//     return this.append(Covered.Flash.create('notice', content));
//   },

//   alert: function(content){
//     return this.append(Covered.Flash.create('alert', content));
//   }

// };
