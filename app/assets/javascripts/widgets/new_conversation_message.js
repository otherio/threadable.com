Rails.widget('new_conversation_message', function(Widget){

  Widget.initialize = function(page){
    page.on('click', '.conversation_messages .attach-files', attachFiles);
    page.on('click', '.conversation_messages .attachment-preview .remove', removeAttachment);
    page.on('ajax:success', '.conversation_messages form', resetForm);
  };

  var ATTACHMENT_PREVIEW_TEMPLATE;

  this.initialize = function(){
    ATTACHMENT_PREVIEW_TEMPLATE = this.node.find('.hidden.attachment-preview').remove().removeClass('hidden');
    this.node.find('input[type=submit]').attr('disabled', true);
    var textarea = this.node.find('textarea');
    textarea.trigger('keyup');
    if (this.data.auto_show_right_text){
      setupNewMessageInput(textarea);
    }else{
      textarea.click(function() { setupNewMessageInput(textarea); });
    }
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

  // private

  function setupNewMessageInput(target){
    var $target = $(target);
    $target.css('height', '200px');
    $target.wysihtml5({'image': false});
    $target.closest('form').find('input[type=submit]').attr('disabled', false);
  }

  function attachFiles(event){
    event.preventDefault();
    $(this).widget(Widget).pickFiles();
  }

  function removeAttachment(event){
    event.preventDefault();
    $(this).closest('.attachment-preview').remove();
  }

  function resetForm(){
    this.reset();
    var form = $(this);

    form.find('.attachments').empty();
    $('ul.wysihtml5-toolbar').remove();
    $('iframe.wysihtml5-sandbox').off('onload').remove();
    form.find('textarea').css('height', '40px').show();
    form.find('input[type=submit]').attr('disabled', true);
  }

});
