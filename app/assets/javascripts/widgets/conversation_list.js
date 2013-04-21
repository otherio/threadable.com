Rails.widget('conversation_list', function(Widget){

  Widget.initialize = function(page){

    page.on('mouseenter', '.conversation_list .conversation', function(event){
      page.trigger('conversation_mouse_enter', $(this).data('conversation-id'));
    });

    page.on('mouseleave', '.conversation_list .conversation', function(event){
      page.trigger('conversation_mouse_leave', $(this).data('conversation-id'));
    });

    page.bind('conversation_mouse_enter', function(event, conversation_id){
      page.$('.conversation_list *[data-conversation-id='+conversation_id+']').addClass('hover');
    });

    page.bind('conversation_mouse_leave', function(event, conversation_id){
      page.$('.conversation_list *[data-conversation-id='+conversation_id+']').removeClass('hover');
    });

  };

});
