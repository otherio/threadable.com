!function(){

  Multify.initialize = function(){
    initializeFlashMessages();
    initializeWidgets();
    initializePage();
    initializeCurrentProject();
    initializeCurrentConversation();
  };

  function initializeFlashMessages(){
    var flash = ENV.flash;
    delete ENV.flash;
    if (!flash) return;
    flash.forEach(function(flash_message){
      var type = flash_message[0], content = flash_message[1];
      Multify.Flash[type](content);
    });
  }

  function initializeWidgets(){
    $.each(Multify.widgets, function(name, widget){
      if (widget.initialize) widget.initialize();
    });
  }

  function initializePage(){
    var page = Multify.pages[Multify.pageName()];
    if (page) page.initialize();
  }

  function initializeCurrentProject(){
    if (!ENV.currentProject) return;
    Multify.currentProject = ENV.currentProject;
  }

  function initializeCurrentConversation(){
    if (!ENV.currentConversation) return;
    Multify.currentConversation = ENV.currentConversation;
  }

}();
