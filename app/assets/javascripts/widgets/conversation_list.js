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

  this.initialize = function(){
    this.node.find('.mute-controls .not_muted_conversations').click(this.show_not_muted_conversations.bind(this));
    this.node.find('.mute-controls .muted_conversations').click(this.show_muted_conversations.bind(this));
  };

  this.show_muted_conversations = function() {
    this.node.find('table.conversations.muted').show();
    this.node.find('table.conversations.not_muted').hide();
    return this;
  };

  this.show_not_muted_conversations = function(){
    this.node.find('table.conversations.muted').hide();
    this.node.find('table.conversations.not_muted').show();
    return this;
  };

});
