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

  widget.onSubmit = function(form, event){
    event.preventDefault();

    var
      root    = form.closest('.tasks_sidebar'),
      input   = form.find('input'),
      subject = input.val();
    if (subject) widget.createTask(root, subject);
    input.val('');
  };

  widget.createTask = function(root, subject){
    var url = root.find('form').attr('action');

    var request = $.ajax({
      url:      url,
      type:    'POST',
      data:     {task:{subject:subject}},
      dataType: 'html'
    });

    request.success(function(html){
      html = $(html);
      root.replaceWith(html);
      setTimeout(function(){ html.find('input:first').focus(); });
    });

    request.error(function(){
      root.find('input:first').val(subject).trigger('keyup');
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

});
