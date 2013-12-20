Covered.Flash = function(node){
  this.node = $(node);
};

Object.extend(Covered.Flash.prototype, {

  create: function(type, html){
    var classnames, title, alert;

    switch(type){
      case 'message':
        classnames = 'message alert-success';
        title      = 'Hey!';
      break;
      case 'error':
        classnames = 'error alert-error';
        title      = 'Error!';
      break;
      case 'notice':
        classnames = 'notice alert-info';
        title      = 'Notice!';
      break;
      case 'alert':
        classnames = 'alert-error';
        title      = 'Alert!';
      break;
    }

    alert = $(
      '<div class="alert">'+
      '  <button type="button" class="close" data-dismiss="alert">×</button>'+
      '  <strong></strong> '+
      '</div>'
    );

    alert.addClass(classnames);
    alert.find('strong').text(title);
    alert.append(html);
    return alert;
  },

  createAndAppendFromText: function(type, text){
    var flash = this.create(type, Covered.Util.text2html(text));
    this.append(flash);
    setTimeout(function(){ flash.fadeOut(function(){ flash.remove(); }); }, 3000);
    return flash;
  },

  empty: function(){
    this.node.empty();
    return this;
  },

  append: function(alert){
    this.node.append(alert);
    return alert;
  },

  message: function(text){
    return this.createAndAppendFromText('message', text);
  },

  error: function(text){
    return this.createAndAppendFromText('error', text);
  },

  notice: function(text){
    return this.createAndAppendFromText('notice', text);
  },

  alert: function(text){
    return this.createAndAppendFromText('alert', text);
  }

});
