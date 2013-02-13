Multify.Widget('tasks_sidebar', function(widget){

  widget.initialize = function(){
    S('.tasks_sidebar')
      ('form')
        .bind('submit', widget.onSubmit)
        ('input')
          .bind('keyup', widget.onValueChange)
        .end
      .end
    ;

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
      dataType: "json"
    });

    request.success(function(){
      widget.reload(root);
    });

    request.error(function(){
      console.log('ERR', arguments);
      root.find('input:first').val(subject);
    });
  };

  widget.reload = function(root){
    var url = root.find('form').attr('action');
    $.getJSON(url, function(tasks){
      root.replaceWith(tasks.as_html);
      setTimeout(function(){
        root.find('input:first').focus();
      });
    })
  };

  widget.onValueChange = function(element){
    var form = element.closest('form');
    var message_body = form.find('input').val();
    form.find('button').attr('disabled', !message_body);
  };

});
