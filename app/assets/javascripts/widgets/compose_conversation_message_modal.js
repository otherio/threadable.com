Rails.widget('compose_conversation_message_modal', function(Widget){

  // This initialization function runs for each instance of this widget
  this.initialize = function(){
    this.node.find('.new_conversation_message').on('ajax:success', onSuccess);
  };

  this.show = function() {
    this.node.modal('show');
    return this;
  };

  this.hide = function(){
    this.node.modal('hide');
    return this;
  };


  function onSuccess(event, conversation, result, xhr) {
    event.stopImmediatePropagation();
    location = xhr.getResponseHeader('location');
  };

});
