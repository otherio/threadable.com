Rails.widget('new_conversation_message', function(Widget){

  Widget.initialize = function(page){
    page.on('keyup', '.conversation_messages form textarea', onMessageBodyChange);
    page.on('click', '.conversation_messages .attach-files', attachFiles);
    page.on('click', '.conversation_messages .attachment-preview .remove', removeAttachment);
  };

  var ATTACHMENT_PREVIEW_TEMPLATE;

  this.initialize = function(){
    this.node.find('textarea').trigger('keyup');
    ATTACHMENT_PREVIEW_TEMPLATE = this.node.find('.hidden.attachment-preview').remove().removeClass('hidden');
  };

  this.pickFiles = function(){
    filepicker.pickAndStore({multiple:true}, {}, function(fpfiles){
      this.addFiles(fpfiles);
    }.bind(this));
  };

  this.addFiles = function(files){
    var nodes = $();
    files.forEach(function(file){
      var node = ATTACHMENT_PREVIEW_TEMPLATE.clone();
      var preview = node.find('.preview');
      node.data('data', file);
      node.attr('title', file.name);

      node.find('input.url'      ).val(file.url);
      node.find('input.filename' ).val(file.filename);
      node.find('input.mimetype' ).val(file.mimetype);
      node.find('input.size'     ).val(file.size);
      node.find('input.writeable').val(file.isWriteable);

      preview.attr('href', file.url);
      if (file.mimetype.indexOf("image") !== -1){
        var img = $('<img>');
        img.attr('src', file.url+'/convert?h=43&w=43&fit=crop');
        preview.html(img);
      }
      nodes = nodes.add(node);
    });
    this.node.find('form .attachments').append(nodes);
  };

  function onMessageBodyChange(){
    var textarea = $(this);
    var form = textarea.closest('form');
    var message_body = form.find('textarea').val();
    form.find('input[type=submit]').attr('disabled', !message_body);
  }

  function attachFiles(event){
    event.preventDefault();
    $(this).widget(Widget).pickFiles();
  }

  function removeAttachment(event){
    event.preventDefault();
    $(this).closest('.attachment-preview').remove();
  }

});
