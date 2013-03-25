Multify.Widget('invite_modal', function(widget){

  Multify.bind('show_invite_modal', function(event, data){
    data || (data={});
    var invite_modal = $('.invite_modal:first');
    invite_modal.find('input[name="invite[name]"]').val(data.name);
    invite_modal.find('input[name="invite[email]"]').val(data.email);
    invite_modal.modal('show');
  });

  widget.initialize = function(){
    widget.S()
      .bind('shown', onShown)
      ('form')
        .bind('ajax:send', onSend)
        .bind('ajax:success', onSuccess)
        .bind('ajax:error', onError)
      .end
    ;

    Multify.bind('show_invite_modal', function(event, options){
      options || (options={});
      var invite_modal = $('.invite_modal:first');
      invite_modal.find('input[name="invite[name]"]').val(options.name);
      invite_modal.find('input[name="invite[email]"]').val(options.email);
      invite_modal.modal('show');
      if(options.success) {
        widget.success = options.success;
      }
    });
  };

  function onShown(modal, event){
    focusFirstInput(modal);
  }

  function onSend(form, event){
    form.closest('.modal').find('.flash_messages').empty();
  }

  function onSuccess(form, event, user, status, xhr){
    close(form.closest('.modal'));
    Multify.Flash.message($('<span>').text(user.name+' <'+user.email+'> was added to this project.'));
    if(widget.success) {
      widget.success(user);
    }
  }

  function onError(form, event, xhr, status, error){
    if (xhr.status === 400){
      Multify.Flash.notice('That user is already a member of this project.');
      close(form.closest('.modal'));
    }else{
      Multify.Modal.Flash.alert('Oops! Something went wrong. Please try again later.');
      focusFirstInput(form);
    }
  }

  function focusFirstInput(element){
    element.find('input:visible:first').focus();
  }

  function close(modal){
    modal.modal('hide');
    modal.find('form')[0].reset();
  }

});
