Multify.Widget('tasks_sidebar', function(widget){

  widget.initialize = function(){
    S('.tasks_sidebar')
      ('form')
        .bind('submit', widget.onSubmit)
        ('input')
          .bind('keyup', widget.onValueChange)
        .end
      .end
      ('.task_list > *')
        .bind('mouseenter', widget.onTaskMouseEnter)
        .bind('mouseleave', widget.onTaskMouseLeave)
      .end
      ('button.all_tasks')
        .bind('click', onClickAllTasksButton)
      .end
      ('button.my_tasks')
        .bind('click', onClickMyTasksButton)
      .end
    ;

    Multify.bind('conversation_mouse_enter', function(event, task_id){
      $('.tasks_sidebar *[data-task-id='+task_id+']').addClass('hover');
    });

    Multify.bind('conversation_mouse_leave', function(event, task_id){
      $('.tasks_sidebar *[data-task-id='+task_id+']').removeClass('hover');
    });

    $(function(){
      $('.tasks_sidebar input').trigger('keyup');
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
      type:     'GET',
      dataType: 'html'
    });

    request.success(function(html){
      widget.replace(html);
    });

    return request;
  };

  widget.replace = function(html){
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
    setTimeout(function(){ element.find('input:first').focus(); });
  };

  widget.onSubmit = function(form, event){
    event.preventDefault();

    var
      root    = form.closest('.tasks_sidebar'),
      input   = form.find('input'),
      subject = input.val();
    if (subject) widget.createTask(root, subject);
    input.val('');

    return widget;
  };

  widget.createTask = function(element, subject){
    element || (element =  widget.$());
    var url = element.find('form').attr('action');

    var request = $.ajax({
      url:      url,
      type:    'POST',
      data:     {task:{subject:subject}},
      dataType: 'html'
    });

    request.success(function(html){
      widget.replace(html);
    });

    request.error(function(){
      element.find('input:first').val(subject).trigger('keyup');
    });
  };

  widget.onValueChange = function(element){
    var form = element.closest('form');
    var message_body = form.find('input').val();
    form.find('button').attr('disabled', !message_body);
  };

  widget.onTaskMouseEnter = function(element){
    Multify.trigger('conversation_mouse_enter', element.data('task-id'));
  };

  widget.onTaskMouseLeave = function(element){
    Multify.trigger('conversation_mouse_leave', element.data('task-id'));
  };

  function onClickAllTasksButton(element){
    element.closest('.tasks_sidebar').attr('showing', 'all_tasks');
  };

  function onClickMyTasksButton(element){
    element.closest('.tasks_sidebar').attr('showing', 'my_tasks');
  };

});
