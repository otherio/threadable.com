Multify.Flash = {

  create: function(type, content){
    var classnames, title, alert;

    switch(type){
      case 'message':
        classnames = 'message alert-success'
        title      = 'Hey!'
      break;
      case 'error':
        classnames = 'error alert-error'
        title      = 'Error!'
      break;
      case 'notice':
        classnames = 'notice alert-info'
        title      = 'Notice!'
      break;
      case 'alert':
        classnames = 'alert-error'
        title      = 'Alert!'
      break;
    }

    alert = $(
      '<div class="alert">'+
      '  <button type="button" class="close" data-dismiss="alert">×</button>'+
      '  <strong></strong> <span></span>'+
      '</div>'
    );

    alert.addClass(classnames);
    alert.find('strong').text(title);
    alert.find('span').html(content);
    return alert;
  },

  append: function(alert){
    $('#page > .flash_messages').append(alert);
    return alert;
  },

  message: function(content){
    return this.append(this.create('message', content));
  },

  error: function(content){
    return this.append(this.create('error', content));
  },

  notice: function(content){
    return this.append(this.create('notice', content));
  },

  alert: function(content){
    return this.append(this.create('alert', content));
  }

};
