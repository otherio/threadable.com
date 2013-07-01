Rails.widget('invite_modal', function(Widget){

  Widget.initialize = function(page){
    page.on('shown',        Widget.selector,      onShown)
    page.on('ajax:send',    Widget.selector+' form', onSend)
    page.on('ajax:success', Widget.selector+' form', onSuccess)
    page.on('ajax:error',   Widget.selector+' form', onError)

    page.bind('show_invite_modal', function(event, options){
      options || (options={});
      var invite_modal = page.$('.invite_modal:first');
      invite_modal.find('input[name="invite[name]"]').val(options.name);
      invite_modal.find('input[name="invite[email]"]').val(options.email);
      invite_modal.modal('show');
      onNextSuccess(invite_modal, options.success);
    });
  };

  this.initialize = function(){
    this.flash = new Covered.Flash(this.node.find('.flash_messages'));
  }

  this.focus = function(){
    this.node.find('input:visible:first').focus();
  };

  this.reset = function(){
    this.flash.empty();
    this.focus();
    this.node.find('form')[0].reset();
    return this;
  };

  this.close = function(){
    this.node.modal('hide');
    this.reset();
  };

  function onNextSuccess(invite_modal, callback){
    if (!callback) return
    invite_modal.one('ajax:success', callback);
    invite_modal.one('ajax:complete', function(){
      invite_modal.unbind('ajax:success', callback);
    });
  }

  function onShown(event){
    $(this).find('input:visible:first').focus();
  }

  function onSend(event){
    $(this).widget(Widget).reset();
  }

  function onSuccess(event, user, status, xhr){
    var widget = $(this).widget(Widget)
    widget.close();
    widget.page().flash.message(user.name+' <'+user.email+'> was added to this project.');
  }

  function onError(event, xhr, status, error){
    var widget = $(this).widget(Widget);
    if (xhr.status === 400){
      widget.page().flash.notice('That user is already a member of this project.');
    }else{
      widget.page().flash.alert('Oops! Something went wrong. Please try again later.');
    }
    widget.close();
  }

});
