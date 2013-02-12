!function(){

  Multify.initialize = function(){
    delete Multify.initialize;
    initializeWidgets();
    initializePage();
    initializeCurrentProject();
    initializeCurrentConversation();
  };

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
    if (!ENV.currentPonversation) return;
    Multify.currentConversation = ENV.currentPonversation;
  }

}();
