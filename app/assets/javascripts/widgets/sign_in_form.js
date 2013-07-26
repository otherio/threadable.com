Rails.widget('sign_in_form', function(Widget){

  Widget.initialize = function(page){
    page.on('ajax:before', Widget.selector+' form', onBefore);
    page.on('ajax:complete', Widget.selector+' form', onComplete);
  };

  this.initialize = function() {
    this.flash_messages = this.node.find('.flash_messages');
    this.flash          = new Covered.Flash(this.flash_messages);
  };

  function onBefore() {
    $(this).widget(Widget).flash.empty();
  }

  function onComplete(event, xhr){
    if (xhr.status === 200){
      window.location = '/';
      return;
    }
    var widget = $(this).widget(Widget);
    var data = JSON.parse(xhr.responseText);
    widget.flash.empty().error(data.error);
    widget.node.animation('shake', '1s');
  }

});
