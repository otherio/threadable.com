Rails.widget('conversation_messages', function(Widget){

  Widget.initialize = function(page){
    page.on('ajax:success', '.conversation_messages form', appendMessage);
  };

  this.initialize = function(){
    this.node.find('.timeago').timeago();
  };

  function appendMessage(event, message, status, request){
    var form = $(this);
    var widget = form.widget(Widget);
    var message = $(message.as_html);
    var li = $('<li>').addClass('with_message').html(message);
    widget.node.find('> ol').append(li);
    message.widget('initialize');
  }

});
