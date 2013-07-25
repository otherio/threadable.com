/*
 * new Covered.Page('.page');
 */
!function(){

  Covered.Page = function(env){
    this.env = env;
    this.name = env.page_name;

    this.current_project      = env.current_project;
    this.current_conversation = env.current_conversation;
    this.current_task         = env.current_task;
    this.current_task_doers   = env.current_task_doers;
    this.current_user         = env.current_user;

    this.bind('domready', onDomready);
  };

  Object.extend(Covered.Page.prototype, Covered.Routes);
  Object.extend(Covered.Page.prototype, Covered.Util.EventFunctions);
  Object.extend(Covered.Page.prototype, {

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
    page.flash = new Covered.Flash(page.$('> .flash_messages'));

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

}();
