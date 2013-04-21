/*
 * new Multify.Page('.page');
 */
!function(){

  Multify.Page = function(env){
    var page = this;
    page.env = env;
    page.name = env.page_name;

    page.current_project      = env.current_project;
    page.current_conversation = env.current_conversation;
    page.current_task         = env.current_task;
    page.current_task_doers   = env.current_task_doers;
    page.current_user         = env.current_user;

    page.bind('domready', onDomready);
  };

  Object.extend(Multify.Page.prototype, Multify.Routes);
  Object.extend(Multify.Page.prototype, Multify.Util.EventFunctions);
  Object.extend(Multify.Page.prototype, {

    $: function(selector){
      return this.node.find(selector);
    },

    on: function(types, selector, data, fn, one){
      this.node.on(types, selector, data, fn, one);
      return this;
    }

  });

  // private

  function onDomready() {
    this.node = $('.page');
    this.node.data('page', this);
    createInitialFlashMessages(this)
    initializeWidgets(this);
  }

  function initializeWidgets(page){
    $.each(Rails.widgets, function(name, widget){
      widget.initialize(page);
    });
    $('*').widget('initialize', page);
  }

  function createInitialFlashMessages(page) {
    page.flash = new Multify.Flash(page.$('> .flash_messages'));

    var i, messages, message, type, content;

    messages = (page.env.flash || []);
    for (i = messages.length - 1; i >= 0; i--) {
      message = messages[i];
      type = message[0];
      content = message[1];
      if (type in page.flash); else type = 'message';
      page.flash[type](content);
    };
  }


  // function initializePage(){
  //   var page = Multify.pages[Multify.pageName()];
  //   if (page) page.initialize();
  // }

//   function initializeCurrentProject(){
//     if (!ENV.currentProject) return;
//     Multify.page.current_project = ENV.currentProject;
//   }

//   function initializeCurrentConversation(){
//     if (!ENV.currentConversation) return;
//     Multify.page.current_conversation = ENV.currentConversation;
//   }

//   function initializeCurrentTask(){
//     if (!ENV.currentTask) return;
//     Multify.currentTask = ENV.currentTask;
//   }

//   function initializeCurrentTaskDoers(){
//     if (!ENV.currentTaskDoers) return;
//     Multify.page.current_task_doers = ENV.currentTaskDoers;
//   }

//   function initializeCurrentUser(){
//     if (!ENV.currentUser) return;
//     Multify.page.current_user = ENV.currentUser;
//   }

}();
