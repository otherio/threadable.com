Multify.Widget('conversation_list', function(widget){

  widget.initialize = function(){
    S('.conversation_list')
      ('.conversations > *')
        .bind('mouseenter', widget.onConversationMouseEnter)
        .bind('mouseleave', widget.onConversationMouseLeave)
      .end
    ;

    Multify.bind('conversation_mouse_enter', function(event, conversation_id){
      $('.conversation_list *[data-conversation-id='+conversation_id+']').addClass('hover');
    });

    Multify.bind('conversation_mouse_leave', function(event, conversation_id){
      $('.conversation_list *[data-conversation-id='+conversation_id+']').removeClass('hover');
    });

  };

  widget.onConversationMouseEnter = function(element){
    Multify.trigger('conversation_mouse_enter', element.data('conversation-id'));
  };

  widget.onConversationMouseLeave = function(element){
    Multify.trigger('conversation_mouse_leave', element.data('conversation-id'));
  };

});
