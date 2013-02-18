Multify.Widget('invite_modal', function(widget){

  widget.initialize = function(){
    widget.S()
      ('.modal')
        .bind('shown', onShown)
      .end
      ('form')
        .bind('ajax:send', onSend)
        .bind('ajax:success', onSuccess)
        .bind('ajax:error', onError)
      .end
    ;
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
