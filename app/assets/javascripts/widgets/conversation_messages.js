Multify.Widget('conversation_messages', function(widget){

  widget.initialize = function(){
    S('.conversation_messages')
      ('form')
        .bind('ajax:success', widget.appendMessage)
        ('textarea')
          .bind('keyup', widget.onMessageBodyChange)
        .end
      .end
    ;

    $(function(){
      $('.conversation_messages textarea').trigger('keyup');
    });
  };

  widget.appendMessage = function(form, event, message, status, request){
    var message_node = $('<li>').addClass('message').html(message.as_html);

    form.closest('.conversation_messages').find('> ol').append(message_node);
    form[0].reset();
    $('.timeago').timeago();
  };

  widget.onMessageBodyChange = function(element){
    var form = element.closest('form');
    var message_body = form.find('textarea').val();
    form.find('input[type=submit]').attr('disabled', !message_body);
  };

});
