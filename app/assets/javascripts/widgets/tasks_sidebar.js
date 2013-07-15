Rails.widget('tasks_sidebar', function(Widget){

  // this runs one time when the dom is ready
  // if this widget was listed in the page digest

  Widget.initialize = function(page){
    page.on('click',      Widget.selector+' button.all_tasks',     onClickAllTasksButton)
    page.on('click',      Widget.selector+' button.my_tasks',      onClickMyTasksButton)
    page.on('click',      Widget.selector+' button.conversations', onClickConversationsButton)
    page.on('submit',     Widget.selector+' form',                 onSubmit)
    page.on('keyup',      Widget.selector+' form input',           onFormValueChange)
    page.on('mouseenter', Widget.selector+' .task',                onTaskMouseEnter)
    page.on('mouseleave', Widget.selector+' .task',                onTaskMouseLeave)

    page.bind('conversation_mouse_enter', function(event, id){
      $(Widget.selector+' *[data-conversation-id='+id+']').addClass('hover');
    });

    page.bind('conversation_mouse_leave', function(event, id){
      $(Widget.selector+' *[data-conversation-id='+id+']').removeClass('hover');
    });

    $(Widget.selector).widget();
  };

  // this runs the first time you call .widget() in a widget dom node
  this.initialize = function(){
    this.node.find('input').trigger('keyup');
    this.node.find('.sortable.task_list').sortable().bind('sortupdate', onSortupdate);
    this.showTab();
  };

  this.showTab = function(tab_name){
    tab_name = tab_name || localStorage['covered.widgets.tasks_sidebar.tab'] || 'all_tasks';
    var button = this.node.find('.btn.'+tab_name);
    if (button.length === 0){
      tab_name = 'all_tasks';
      button = this.node.find('.btn.'+tab_name);
    }
    localStorage['covered.widgets.tasks_sidebar.tab'] = tab_name;
    this.node.attr('showing', tab_name);
    button.addClass('active').siblings().removeClass('active');
    return this;
  };

  this.createTask = function(subject){
    var url = this.node.find('form').attr('action');

    var data = {task:{subject:subject}};

    var request = $.ajax({
      context:  this,
      url:      url,
      type:    'POST',
      data:     data,
      dataType: 'html'
    });

    request.success(function(html){
      request.new_widget = this.replace(html);
    });

    return request;
  };

  this.replace = function(html){
    var tab = this.node.attr('showing');
    var node = $(html);
    this.node.replaceWith(node);
    var widget = node.widget();
    widget.showTab(tab);
    return widget;
  };

  this.reload = function(){
    return $.ajax({
      url:      this.node.find('form').attr('action'),
      type:     'GET',
      dataType: 'html',
      success:  this.replace.bind(this)
    });
  };



  // private

  function onClickAllTasksButton(event){
    $(this).widget().showTab('all_tasks');
  }

  function onClickMyTasksButton(event){
    $(this).widget().showTab('my_tasks');
  }

  function onClickConversationsButton(event){
    $(this).widget().showTab('conversations');
  }

  function onFormValueChange(event){
    var form = $(this).widget().node.find('form');
    var message_body = form.find('input').val();
    form.find('button').attr('disabled', !message_body);
  }

  function onSubmit(event){
    event.preventDefault();
    var
      form    = $(this),
      input   = form.find('input'),
      subject = input.val();

    if (!subject) return;
    var create = $(this).widget().createTask(subject);

    create.success(function(){
      setTimeout(function(){
        create.new_widget.node.find('form input').focus();
      });
    });

    create.fail(function(){ input.val(subject); });

    input.val('');
  }

  function onTaskMouseEnter(event){
    Covered.page.trigger('conversation_mouse_enter', $(this).data('conversation-id'));
  }

  function onTaskMouseLeave(event){
    Covered.page.trigger('conversation_mouse_leave', $(this).data('conversation-id'));
  }

  function onSortupdate(event, data){
    var
      task             = data.item,
      list             = $(this),
      widget           = list.closest(Widget.selector).widget(),
      tasks            = list.find('>li'),
      index            = task.index(),
      current_position = task.data('position'),
      new_position, url;

    if (index < 1){
      new_position = $(tasks.get(index+1)).data('position') - 1
    }else{
      new_position = $(tasks.get(index-1)).data('position')

      if (current_position >= new_position) new_position++;
    }

    if (!$.isNumeric(new_position)) throw new Error('unable to determine new position');

    url = this.page().project_task_path(
      this.page().current_project.slug, task.data('slug')
    );

    $.ajax({
      url: url,
      type: 'PUT',
      dataType: 'json',
      data: {task:{position: new_position}},
      success: function(){ widget.reload(); }
    });
  }

});
