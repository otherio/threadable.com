Rails.widget('sign_in_form', function(Widget){

  Widget.initialize = function(page){
    page.on('ajax:before', Widget.selector+' form', onBefore);
    page.on('ajax:complete', Widget.selector+' form', onComplete);
  };

  this.initialize = function() {
    this.flash = new Covered.Flash(this.node.find('.flash_messages'));
    this.state_input = this.node.find('input.state');
    this.sign_in_form_email_input = this.node.find('.sign-in-form input.email');
    this.recover_password_form_email_input = this.node.find('.recover-password-form input.email');
    this.node.find('.recover-password').click(this.proxy('showRecoverPasswordForm'));
    this.node.find('.sign-in').click(this.proxy('showSignInForm'));

    var initial_state = 'sign in';
    if (Covered.page_loaded_from_back_button) initial_state = this.state_input.val() || initial_state;
    this.state(initial_state);

    this.node.find('.done .message').text( this.node.find('.done .message-store').val() );

    this.node.css({visibility: 'visible'});
  };

  this.state = function(state){
    if (arguments.length === 0) return this.node.attr('state');
    this.node.attr('state', state);
    this.node.addClass('update-state').removeClass('update-state');
    this.state_input.val(state);
  }

  this.showRecoverPasswordForm = function() {
    this.recover_password_form_email_input.val( this.sign_in_form_email_input.val() );
    this.state('recover password');
    return this;
  };

  this.showSignInForm = function() {
    this.sign_in_form_email_input.val( this.recover_password_form_email_input.val() );
    this.state('sign in');
    return this;
  };

  this.showDone = function(message) {
    this.state('done');
    this.node.find('.done .message').text(message);
    this.node.find('.done .message-store').val(message);
    return this;
  };

  function onBefore() {
    $(this).widget(Widget).flash.empty();
  }

  function onComplete(event, xhr){

    var data = JSON.parse(xhr.responseText);
    var widget = $(this).widget(Widget);

    if (data.redirect_to){
      window.location = data.redirect_to;
      return;
    }

    if (data.error){
      widget.flash.error(data.error);
      return;
    }

    if (data.fail){
      widget.node.animation('shake', '1s')
      widget.node.addClass('shake'); // this is only done for testing
      return;
    }

    if (data.done){
      widget.showDone(data.done);
      return;
    }
  }

});
