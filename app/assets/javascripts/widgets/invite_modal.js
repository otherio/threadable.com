Rails.widget('invite_modal', function(Widget){

  Widget.initialize = function(page){
    page.on('shown',        Widget.selector,         onShown);
    page.on('ajax:send',    Widget.selector+' form', onSend);
    page.on('ajax:success', Widget.selector+' form', onSuccess);
    page.on('ajax:error',   Widget.selector+' form', onError);
    page.bind('show_invite_modal', showInviteModal);
  };

  this.initialize = function(){
    this.form           = this.$('form');
    this.name_input     = this.$('input[name="invite[name]"]');
    this.email_input    = this.$('input[name="invite[email]"]');
    this.flash_messages = this.node.find('.flash_messages');
    this.flash          = new Covered.Flash(this.flash_messages);
  }

  this.show = function() {
    this.node.modal('show');
    return this;
  };

  this.hide = function(){
    this.node.modal('hide');
    this.reset();
    this.$(':focus').blur();
    return this;
  };

  this.focus = function(){
    this.node.find('input:visible:first').focus();
    return this;
  };

  this.reset = function(){
    this.flash.empty();
    this.form[0].reset();
    this.focus();
    return this;
  };

  function showInviteModal(event, options){
     options || (options={});
     var widget = this.$('.invite_modal:first').widget();
     widget.name_input.val(options.name);
     widget.email_input.val(options.email);
     widget.node.modal('show');
     onNextSuccess(widget, options.success);
   }

  function onNextSuccess(widget, callback){
    if (!callback) return
    widget.form.one('ajax:success', callback);
    widget.form.one('ajax:complete', function(){
      widget.form.unbind('ajax:success', callback);
    });
  }

  function onShown(event){
    $(this).widget(Widget).focus();
  }

  function onSend(event){
    $(this).widget(Widget).reset();
  }

  function onSuccess(event, user, status, xhr){
    var widget = $(this).widget(Widget)
    widget.hide();
    widget.page().flash.message(user.name+' <'+user.email+'> was added to this project.');
  }

  function onError(event, xhr, status, error){
    var widget = $(this).widget(Widget);
    if (xhr.status === 400){
      widget.page().flash.notice('That user is already a member of this project.');
    }else{
      widget.page().flash.alert('Oops! Something went wrong. Please try again later.');
    }
    widget.hide();
  }

});
