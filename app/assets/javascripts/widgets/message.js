Rails.widget('message', function(Widget){

  Widget.initialize = function(page){
    page.on('ajax:success', this.selector+' a.shareworthy, '+this.selector+' a.knowledge', success);
    page.on('click', this.selector+' .show-quoted-text', showQuotedText);
  };

  this.initialize = function(){
    this.node.timeago();
  };

  function success(event, message){
    var html = $(message.as_html);
    $(this).widget(Widget).node.replaceWith(html);
    html.widget();
  }

  function showQuotedText(){
    $(this).closest('.message-body').addClass('show-full');
  }

});
