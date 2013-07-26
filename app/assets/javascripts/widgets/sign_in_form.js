Rails.widget('sign_in_form', function(Widget){

  Widget.initialize = function(page){
    page.on('ajax:before', Widget.selector+' form', onBefore);
    page.on('ajax:complete', Widget.selector+' form', onComplete);
  };

  function onBefore() {
    Covered.page.flash.empty();
  }

  function onComplete(event, xhr){
    if (xhr.status === 200){
      window.location = '/';
      return;
    }
    var widget = $(this).widget(Widget);
    var data = JSON.parse(xhr.responseText);
    widget.page().flash.empty();
    widget.page().flash.error(data.error);
    widget.node.animation('shake', '1s');
  }

});
