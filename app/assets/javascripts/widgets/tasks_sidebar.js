Multify.Widget('tasks_sidebar', function(widget){

  widget.initialize = function(){
    S('.tasks_sidebar')
      ('form')
        .bind('submit', widget.onSubmit)
        ('input')
          .bind('keyup', widget.onValueChange)
        .end
      .end
      ('.task')
        .bind('mouseenter', widget.onTaskMouseEnter)
        .bind('mouseleave', widget.onTaskMouseLeave)
      .end
      ('button.all_tasks')
        .bind('click', onClickAllTasksButton)
      .end
      ('button.my_tasks')
        .bind('click', onClickMyTasksButton)
      .end
      ('button.conversations')
        .bind('click', onClickConversationsButton)
      .end
    ;

    Multify.bind('conversation_mouse_enter', function(event, id){
      widget.$('*[data-conversation-id='+id+']').addClass('hover');
    });

    Multify.bind('conversation_mouse_leave', function(event, id){
      widget.$('*[data-conversation-id='+id+']').removeClass('hover');
    });

    $(function(){
      widget.reset();
    });
  };

  widget.path = function(element){
    element || (element =  widget.$());
    return element.find('form').attr('action');
  };

  widget.reload = function(element){
    element || (element = widget.$());

    var request = $.ajax({
      url:      widget.path(),
      data:     element.closest('.tasks_sidebar').data(),
      type:     'GET',
      dataType: 'html'
    });

    request.success(function(html){
      widget.replace(html);
    });

    return request;
  };

  widget.replace = function(html, refocus){
    var element = widget.$();
    html = $(html);
    element = element.map(function(){
      var
        instance = $(this),
        showing  = instance.attr('showing'),
        new_html = html.clone();
      instance.replaceWith(new_html);
      new_html.find('button.'+showing).click();
      return new_html[0];
    });
    widget.reset();
    if (refocus) setTimeout(function(){ element.find('input:first').focus(); });
  };

  widget.reset = function(element){
    $('.tasks_sidebar input').trigger('keyup');
    $('.tasks_sidebar .sortable.task_list').sortable().bind('sortupdate', widget.sortupdate);
    widget.showTab();
  };

  widget.onSubmit = function(form, event){
    event.preventDefault();

    var
      root    = form.closest('.tasks_sidebar'),
      input   = form.find('input'),
      subject = input.val();
    if (subject) widget.createTask(root, subject, true);
    input.val('');

    return widget;
  };

  widget.createTask = function(element, subject, refocus){
    element || (element =  widget.$());
    var url = element.find('form').attr('action');

    var data = $.extend(element.closest('.tasks_sidebar').data(), {task:{subject:subject}});

    var request = $.ajax({
      url:      url,
      type:    'POST',
      data:     data,
      dataType: 'html'
    });

    request.success(function(html){
      widget.replace(html, refocus);
    });

    request.error(function(){
      element.find('input:first').val(subject).trigger('keyup');
    });
  };

  widget.showTab = function(tab_name, element){
    element || (element =  widget.$());
    element = element.closest('.tasks_sidebar');
    tab_name = tab_name || localStorage['multify.widgets.tasks_sidebar.tab'] || 'all_tasks';
    var button = element.find('.btn.'+tab_name);
    if (button.length === 0){
      tab_name = 'all_tasks';
      button = element.find('.btn.'+tab_name);
    }
    localStorage['multify.widgets.tasks_sidebar.tab'] = tab_name;
    element.attr('showing', tab_name);
    button.addClass('active').siblings().removeClass('active');
    return widget;
  };

  widget.onValueChange = function(element){
    var form = element.closest('form');
    var message_body = form.find('input').val();
    form.find('button').attr('disabled', !message_body);
  };

  widget.onTaskMouseEnter = function(element){
    Multify.trigger('conversation_mouse_enter', element.data('conversation-id'));
  };

  widget.onTaskMouseLeave = function(element){
    Multify.trigger('conversation_mouse_leave', element.data('conversation-id'));
  };

  widget.sortupdate = function(event, data){
    var task = data.item;
    var list = $(this);
    var tasks = list.find('>li');
    var index = task.index();
    var current_position = task.data('position');
    var new_position;
    if (index < 1){
      new_position = $(tasks.get(index+1)).data('position') - 1
    }else{
      new_position = $(tasks.get(index-1)).data('position')

      if (current_position >= new_position) new_position++;
    }

    if (!$.isNumeric(new_position)) throw new Error('unabled to determine new position');

    var url = Multify.project_task_path(
      Multify.currentProject.slug, task.data('slug')
    );

    var request = $.ajax({
      url: url,
      type: 'PUT',
      dataType: 'json',
      data: {task:{position: new_position}}
    });

    request.done(function(){
      widget.reload(list);
    });
  };

  function onClickAllTasksButton(element){
    widget.showTab('all_tasks', element);
  };

  function onClickMyTasksButton(element){
    widget.showTab('my_tasks', element);
  };

  function onClickConversationsButton(element){
    widget.showTab('conversations', element);
  };



});
