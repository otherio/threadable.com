Rails.widget('conversation_messages', function(Widget){

  Widget.initialize = function(page){
    page.on('ajax:success', '.conversation_messages form', appendMessage);
  };

  this.initialize = function(){
    this.node.find('.timeago').timeago();
    this.highlightMessage(messageIdInHash());
  };

  this.highlightMessage = function(id){
    this.node.find('#message-'+id).addClass('highlight');
    return this;
  };

  function appendMessage(event, message, status, request){
    var form = $(this);
    var widget = form.widget(Widget);
    var message = $(message.as_html);
    var li = $('<li>').addClass('with_message').html(message);
    widget.node.find('> ol').append(li);
    message.addClass('tada');
    message.widget('initialize');
  }

  function messageIdInHash() {
    var matches = location.hash.match(/message-(\d+)/);
    if (matches) return matches[1];
  }

});
