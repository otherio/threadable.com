Rails.widget('conversation_messages', function(Widget){

  Widget.initialize = function(page){
    page.on('ajax:success', '.conversation_messages form', appendMessage);
    page.on('keyup', '.conversation_messages form textarea', onMessageBodyChange);
  };

  this.initialize = function(){
    this.node.find('textarea').trigger('keyup');
    this.node.find('.timeago').timeago();
  };

  function appendMessage(event, message, status, request){
    var form = $(this);
    var widget = form.widget(Widget);
    var message = $(message.as_html);
    var li = $('<li>').addClass('with_message').html(message);
    widget.node.find('> ol').append(li);
    this.reset();
    message.widget('initialize');
  }

  function onMessageBodyChange(){
    var form = $(this).closest('form');
    var message_body = form.find('textarea').val();
    form.find('input[type=submit]').attr('disabled', !message_body);
  }

});
