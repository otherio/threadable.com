Multify.Widget('message', function(widget){

  widget.initialize = function(){
    widget.S
      ('a.shareworthy, a.knowledge')
        .bind('ajax:success', function(a, event, message){
          html = $(message.as_html)
          a.closest('.message').replaceWith(html);
          html.timeago();
        })
      .end
    ;
  };

});
